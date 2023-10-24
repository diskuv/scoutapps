package com.example.squirrelscout.data;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;

import androidx.core.os.HandlerCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleRegistry;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.models.ComDataAndProductionTestModel;
import com.example.squirrelscout.data.models.ComDataModel;

/**
 * An Android Service component that will start an OCaml runtime
 * while the application is in the foreground and shutdown
 * the OCaml runtime when the application goes to the background.
 * <p>
 * The OCaml runtime is in run in a service thread (not the main UI thread).
 *
 * <ol>
 * <li>The ability to shutdown (remove registrations).</li>
 * <li>The ability to spawn a background thread that runs the
 * OCaml code and will be tracked by Android, and stopped if Android
 * needs the memory.</li>
 * </ol>
 *
 * <h2>Restrictions</h2>
 * <p>
 * Because the OCaml service background thread can be stopped
 * by Android due to memory pressure, anything transient memory inside
 * OCaml can be lost. In addition, the OCaml runtime will be shutdown
 * simply for going into the background. That means the OCaml top-level
 * statements should be quick for the startup; if not when the app
 * comes to the foreground the user will experience a pause.
 * </p>
 * <p>All of the restrictions means that the OCaml runtime is good
 * for responding to UI events, quickly placing data into
 * persistence, and informing the UI of data changes.</p>
 *
 * <h2>Technical Requirements</h2>
 * <p>
 * All OCaml events (initialization, etc.) are done from the OCaml service
 * background thread. Why? OCaml needs locks to operate from multiple
 * threads.
 * <p>
 * All data lifecycle events are done from the main UI thread. Why?
 * Android will fail when setting the lifecycle state from any other
 * thread.
 */
public class ComDataForegroundService extends Service {
    // POINT B: Initialize the OCaml code, which will do caml_startup()
    // and run all the top-level `let () =` statements as well.
    private static native boolean init_ocaml(String processArg0);

    // POINT C: Start the OCaml runtime (currently does nothing)
    private static native void start_ocaml(String processArg0);

    // Must be idempotent since can be called twice.
    //
    // POINT C ALTERNATE: Stop the OCaml runtime which removes all OCaml values
    // from the garbage collector.
    // POINT C: Does nothing.
    private static native void stop_ocaml();

    // [POINT B ALTERNATE]: caml_shutdown() to do DkSDK FFI OCaml
    // class object de-registrations if OCaml could repeatedly
    // run caml_startup() -> caml_shutdown(). Sadly it can't yet.
    // [POINT B]: Does nothing.
    private static native void terminate_ocaml();

    // [POINT B]: Shutdown OCaml
    private static native void atexit_ocaml();

    private static OCamlServiceHandler globalOCamlServiceHandler;
    private static Com gCom;
    private final ComFactory.ComDomain comDomain = hasProductionTestObjects() ? ComFactory.ComDomain.PRODUCTION_TEST : ComFactory.ComDomain.PRODUCTION;
    private final IBinder binder = new ComDataBinder();
    private final Handler uiThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper());

    private volatile ComDataModel data;
    private LifecycleRegistry dataLifecycleRegistry;

    public final class ComDataBinder extends Binder {
        public ComDataForegroundService getService() {
            return ComDataForegroundService.this;
        }
    }

    enum HandlerMessageType {
        MSG_INIT,
        MSG_START,
        MSG_STOP,
        MSG_DESTROY
    }

    // Handler that receives messages for the OCaml service thread
    private final class OCamlServiceHandler extends Handler {
        public OCamlServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            if (msg.arg1 == HandlerMessageType.MSG_INIT.ordinal())
                handleInitMessage();
            if (msg.arg1 == HandlerMessageType.MSG_START.ordinal())
                handleStartMessage();
            if (msg.arg1 == HandlerMessageType.MSG_STOP.ordinal())
                handleStopMessage();
            if (msg.arg1 == HandlerMessageType.MSG_DESTROY.ordinal())
                handleDestroyMessage();
        }

        private void handleInitMessage() {
            // [POINT B]
            init_ocaml(getPackageName());
        }

        private void handleStartMessage() {
            // [POINT C]
            start_ocaml(getPackageName());

            // [POINT D]: Do all the borrowing of class objects in ComData.
            final ComDataModel data0;
            final LifecycleRegistry[] registry0 = new LifecycleRegistry[1];
            ComDataModel.LifecycleRegistrySetter registrySetter = lifecycleRegistry -> registry0[0] = lifecycleRegistry;
            switch (comDomain) {
                case PRODUCTION:
                    data0 = new ComDataModel(gCom, getApplicationContext(), registrySetter);
                    break;
                case PRODUCTION_TEST:
                    data0 = new ComDataAndProductionTestModel(gCom, getApplicationContext(), registrySetter);
                    break;
                default:
                    throw new IllegalStateException("No COM domain " + comDomain);
            }
            assert registry0[0] != null;
            synchronized (ComDataForegroundService.class) {
                data = data0;
                dataLifecycleRegistry = registry0[0];
            }

            // switch from the OCaml thread to the UI thread
            uiThreadHandler.post(() -> {
                // [data] is STARTED. Lifecycle state must be set on main UI thread.
                dataLifecycleRegistry.setCurrentState(Lifecycle.State.CREATED);
                dataLifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
            });
        }

        private void handleStopMessage() {
            // switch from the OCaml thread to the UI thread
            uiThreadHandler.post(() -> {
                // [POINT D]: Would be nice that we could release the borrowing
                // of class objects in ComData. But the class objects
                // can live until Java garbage collection (and the user
                // may be accidentally holding onto them).
                // For now, we simply stop any more use of [data].
                synchronized (ComDataForegroundService.class) {
                    // [data] will be DESTROYED. Lifecycle state must be set on main UI thread.
                    dataLifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
                    data = null;
                }

                // switch from UI thread back to OCaml thread.
                // In OCaml thread will be [POINT C, POINT C ALTERNATE]
                post(ComDataForegroundService::stop_ocaml);
            });
        }

        private void handleDestroyMessage() {
            // Since we can't know whether STOP has finished, we do STOP immediately
            // and rely on <stop_ocaml> idempotency.
            // [POINT C, POINT C ALTERNATE]
            stop_ocaml();

            // [POINT B, POINT B ALTERNATE]
            terminate_ocaml();
        }
    }

    protected boolean hasProductionTestObjects() {
        return false;
    }

    protected String getLogName() {
        return null;
    }

    @Override
    public void onCreate() {
        synchronized (ComDataForegroundService.class) {
            // [POINT A]: Do dksdk_ffi_host_create(), standard DkSDK FFI C class object registrations
            // and a service thread for OCaml
            if (gCom == null) {

                // Start up the thread running the service. Note that we create a
                // separate thread because the service normally runs in the process's
                // main thread, which we don't want to block. We also make it
                // background priority so CPU-intensive work doesn't disrupt our UI.
                HandlerThread thread = new HandlerThread("ComDataForeground",
                        android.os.Process.THREAD_PRIORITY_BACKGROUND);
                thread.start();

                // Get the HandlerThread's Looper and use it for our Handler
                Looper serviceLooper = thread.getLooper();
                globalOCamlServiceHandler = new OCamlServiceHandler(serviceLooper);

                // Create COM and its shutdown handlers
                gCom = ComFactory.createDataForeground(getLogName(), comDomain);
                Runtime.getRuntime().addShutdownHook(new Thread() {
                    @Override
                    public void run() {
                        // [POINT B]
                        atexit_ocaml();

                        // [POINT A]: Stop servicing messages, do DkSDK FFI C class object
                        // de-registrations (ex. ICallable, Posix::FILE) and then
                        // dksdk_ffi_host_destroy()
                        thread.quitSafely();
                        gCom.shutdown();
                    }
                });
            }
        }

        // Send INIT message which will do POINT B
        Message msg = globalOCamlServiceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_INIT.ordinal();
        globalOCamlServiceHandler.sendMessage(msg);
    }

    public void requestData(ComDataRequestCallback callback) {
        // Posting to the service thread makes sure the first service
        // thread message (start OCaml) has been completed.
        //
        // Also, being in the service thread means we don't have to
        // work about whether OCaml has been registered in the thread
        // if the data accessed needs to call back into OCaml.
        globalOCamlServiceHandler.post(() -> {
            ComDataModel data0 = data;
            if (data0 != null) /* ensure no more delivery after shutdown */
                callback.onComDataReady(data0);
        });
    }

    @Override
    public IBinder onBind(Intent intent) {
        // BEHAVIOR:
        // Android will only do an onBind() once and then it will
        // return the same memoized IBinder object.

        // Send START message which will do POINT C + D
        Message msg = globalOCamlServiceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_START.ordinal();
        globalOCamlServiceHandler.sendMessage(msg);

        return binder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        // Send STOP message which will undo POINT D + C
        Message msg = globalOCamlServiceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_STOP.ordinal();
        globalOCamlServiceHandler.sendMessage(msg);

        /* Do not call onRebind() when a new bind comes in */
        return false;
    }

    @Override
    public void onDestroy() {
        // Send DESTROY message which will undo POINT B ALTERNATE
        Message msg = globalOCamlServiceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_DESTROY.ordinal();
        globalOCamlServiceHandler.sendMessage(msg);
    }
}