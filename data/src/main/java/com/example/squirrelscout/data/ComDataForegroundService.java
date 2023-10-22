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
    private static native void initializeOCamlRuntime(String processArg0);

    private static native void shutdownOCaml();

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
        MSG_STARTUP,
        MSG_SHUTDOWN
    }

    // Handler that receives messages for the service thread
    private final class ComDataHandler extends Handler {
        private boolean initted;

        public ComDataHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            if (msg.arg1 == HandlerMessageType.MSG_STARTUP.ordinal())
                handleStartupMessage();
            if (msg.arg1 == HandlerMessageType.MSG_SHUTDOWN.ordinal())
                handleShutdownMessage();
        }

        private void handleStartupMessage() {
            // POINT B: Initialize the OCaml code, which will run all the
            // top-level `let () =` statements as well.
            synchronized (ComDataHandler.class) {
                // Only do OCaml initialization once
                if (initted) return;
                initted = true;
            }
            initializeOCamlRuntime(getPackageName());

            // POINT C: Do all the borrowing of class objects in ComData.
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

        private void handleShutdownMessage() {
            // POINT C: Would be nice that we could release the borrowing
            // of class objects in ComData. But the class objects
            // can live until Java garbage collection (and the user
            // may be accidentally holding onto them).
            // For now, we simply stop any more use of [data].
            ComDataModel data0 = data;
            synchronized (ComDataForegroundService.class) {
                data = null;
            }

            // POINT B: caml_shutdown() which should do DkSDK FFI OCaml
            // class object de-registrations.
            shutdownOCaml();

            // POINT A: Do DkSDK FFI C class object de-registrations (ex.
            // ICallable, Posix::FILE) and then dksdk_ffi_host_destroy()
            com.shutdown();
        }
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

        // POINT A: Do dksdk_ffi_host_create() and standard DkSDK FFI C class object registrations
        boolean productionTest = intent.getBooleanExtra("Com.productionTest", false);
        comDomain = productionTest ? ComFactory.ComDomain.PRODUCTION_TEST : ComFactory.ComDomain.PRODUCTION;
        com = ComFactory.createDataForeground(intent, comDomain);

        // Send startup message (B + C)
        Message msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_STARTUP.ordinal();
        serviceHandler.sendMessage(msg);

        return binder;
    }

    @Override
    public void onDestroy() {
        // Send shutdown message (C + B + A)
        Message msg = serviceHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_SHUTDOWN.ordinal();
        serviceHandler.sendMessage(msg);
    }
}