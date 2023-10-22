package com.example.squirrelscout.data;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.widget.Toast;

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
 */
public class ComDataForegroundService extends Service {
    private static native void init_ocaml(String processArg0);
    private static native void start_ocaml();
    private static native void stop_ocaml();
    private static native void terminate_ocaml();

    private ComFactory.ComDomain comDomain;
    private Com com;
    private volatile ComDataModel data;
    private ComDataHandler serviceHandler;
    private final IBinder binder = new ComDataBinder();

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

    // Handler that receives messages for the service thread
    private final class ComDataHandler extends Handler {
        private boolean initted;

        public ComDataHandler(Looper looper) {
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
            // POINT B: Initialize the OCaml code, which will run all the
            // top-level `let () =` statements as well.
            init_ocaml(getPackageName());
        }

        private void handleStartMessage() {
            // POINT C: Start the OCaml runtime (currently does nothing)
            start_ocaml();

            // POINT D: Do all the borrowing of class objects in ComData.
            final ComDataModel data0;
            switch (comDomain) {
                case PRODUCTION:
                    data0 = new ComDataModel(com, getApplicationContext());
                    break;
                case PRODUCTION_TEST:
                    data0 = new ComDataAndProductionTestModel(com, getApplicationContext());
                    break;
                default:
                    throw new IllegalStateException("No COM domain " + comDomain);
            }
            synchronized (ComDataForegroundService.class) {
                data = data0;
            }
        }

        private void handleStopMessage() {
            // POINT D: Would be nice that we could release the borrowing
            // of class objects in ComData. But the class objects
            // can live until Java garbage collection (and the user
            // may be accidentally holding onto them).
            // For now, we simply stop any more use of [data].
            synchronized (ComDataForegroundService.class) {
                data = null;
            }

            // POINT C: Stop the OCaml runtime (currently removes all OCaml values)
            stop_ocaml();
        }

        private void handleDestroyMessage() {
            // POINT B: caml_shutdown() which should do DkSDK FFI OCaml
            // class object de-registrations.
            terminate_ocaml();

            // POINT A: Do DkSDK FFI C class object de-registrations (ex.
            // ICallable, Posix::FILE) and then dksdk_ffi_host_destroy()
            com.shutdown();
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
        // Start up the thread running the service. Note that we create a
        // separate thread because the service normally runs in the process's
        // main thread, which we don't want to block. We also make it
        // background priority so CPU-intensive work doesn't disrupt our UI.
        HandlerThread thread = new HandlerThread("ComDataHandler",
                android.os.Process.THREAD_PRIORITY_BACKGROUND);
        thread.start();

        // Get the HandlerThread's Looper and use it for our Handler
        Looper serviceLooper = thread.getLooper();
        serviceHandler = new ComDataHandler(serviceLooper);

        // POINT A: Do dksdk_ffi_host_create() and standard DkSDK FFI C class object registrations
        comDomain = hasProductionTestObjects() ? ComFactory.ComDomain.PRODUCTION_TEST : ComFactory.ComDomain.PRODUCTION;
        com = ComFactory.createDataForeground(getLogName(), comDomain);

        // Send INIT message which will do POINT B
        Message msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_INIT.ordinal();
        serviceHandler.sendMessage(msg);
    }

    public void requestData(ComDataRequestCallback callback) {
        // Posting to the service thread makes sure the first service
        // thread message (start OCaml) has been completed.
        //
        // Also, being in the service thread means we don't have to
        // work about whether OCaml has been registered in the thread
        // if the data accessed needs to call back into OCaml.
        serviceHandler.post(() -> {
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
        msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_START.ordinal();
        serviceHandler.sendMessage(msg);

        return binder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        // Send STOP message which will undo POINT D + C
        msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_STOP.ordinal();
        serviceHandler.sendMessage(msg);

        /* Do not call onRebind() when a new bind comes in */
        return false;
    }

    @Override
    public void onDestroy() {
        // Send DESTROY message which will undo POINT B + A
        Message msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_DESTROY.ordinal();
        serviceHandler.sendMessage(msg);
    }
}