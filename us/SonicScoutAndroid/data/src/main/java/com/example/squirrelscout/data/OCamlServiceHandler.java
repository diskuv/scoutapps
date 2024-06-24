package com.example.squirrelscout.data;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import androidx.core.os.HandlerCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleRegistry;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.models.ComDataAndProductionTestModel;
import com.example.squirrelscout.data.models.ComDataModel;

import java.util.concurrent.atomic.AtomicReference;

/**
 * Handler that receives messages for the OCaml service thread.
 */
public final class OCamlServiceHandler extends Handler {
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

    private static Com gCom;

    private final String packageName;
    private final ComFactory.ComDomain comDomain;
    private final Handler uiThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper());

    private final AtomicReference<Context> applicationContextRef;

    private ComDataModel data;
    private LifecycleRegistry dataLifecycleRegistry;

    private OCamlServiceHandler(Looper looper, String packageName, ComFactory.ComDomain comDomain) {
        super(looper);
        this.applicationContextRef = new AtomicReference<>();
        this.packageName = packageName;
        this.comDomain = comDomain;
    }

    public static synchronized OCamlServiceHandler create(
            String logName, String packageName, ComFactory.ComDomain comDomain) {
        // [POINT A]: Do dksdk_ffi_host_create(), standard DkSDK FFI C class object registrations
        // and a service thread for OCaml

        // Start up the thread running the service. Note that we create a
        // separate thread because the service normally runs in the process's
        // main thread, which we don't want to block. We also make it
        // background priority so CPU-intensive work doesn't disrupt our UI.
        HandlerThread thread = new HandlerThread("OCamlServiceHandler",
                android.os.Process.THREAD_PRIORITY_BACKGROUND);
        thread.start();

        // Create COM and its shutdown handlers
        gCom = ComFactory.createDataForeground(logName, comDomain);
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                // [POINT B]
                OCamlServiceHandler.atexit_ocaml();

                // [POINT A]: Stop servicing messages, do DkSDK FFI C class object
                // de-registrations (ex. ICallable, Posix::FILE) and then
                // dksdk_ffi_host_destroy()
                thread.quitSafely();
                gCom.shutdown();
            }
        });

        // Get the HandlerThread's Looper and use it for our Handler
        Looper serviceLooper = thread.getLooper();
        return new OCamlServiceHandler(serviceLooper, packageName, comDomain);
    }

    public synchronized void updateActiveForegroundService(Context applicationContext) {
        applicationContextRef.set(applicationContext);
    }

    public synchronized ComDataModel getData() {
        return data;
    }

    @Override
    public void handleMessage(Message msg) {
        if (msg.arg1 == ComDataForegroundService.HandlerMessageType.MSG_INIT.ordinal())
            handleInitMessage();
        if (msg.arg1 == ComDataForegroundService.HandlerMessageType.MSG_START.ordinal())
            handleStartMessage();
        if (msg.arg1 == ComDataForegroundService.HandlerMessageType.MSG_STOP.ordinal())
            handleStopMessage();
        if (msg.arg1 == ComDataForegroundService.HandlerMessageType.MSG_DESTROY.ordinal())
            handleDestroyMessage();
    }

    private void handleInitMessage() {
        // [POINT B]
        init_ocaml(packageName);
    }

    private void handleStartMessage() {
        // Do nothing if we have no application context to start ComDataModel
        Context context = applicationContextRef.get();
        if (context == null) {
            Log.w("OCamlServiceHandler",
                    "No active foreground service set with updateActiveForegroundService()");
            return;
        }

        // [POINT C]
        start_ocaml(packageName);

        // [POINT D]: Do all the borrowing of class objects in ComData.
        final ComDataModel data0;
        final LifecycleRegistry[] registry0 = new LifecycleRegistry[1];
        ComDataModel.LifecycleRegistrySetter registrySetter = lifecycleRegistry -> registry0[0] = lifecycleRegistry;
        switch (comDomain) {
            case PRODUCTION:
                data0 = new ComDataModel(gCom, context, registrySetter);
                break;
            case PRODUCTION_TEST:
                data0 = new ComDataAndProductionTestModel(gCom, context, registrySetter);
                break;
            default:
                throw new IllegalStateException("No COM domain " + comDomain);
        }
        assert registry0[0] != null;
        synchronized (OCamlServiceHandler.class) {
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
            synchronized (OCamlServiceHandler.class) {
                // [data] will be DESTROYED. Lifecycle state must be set on main UI thread.
                dataLifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
                data = null;
            }

            // switch from UI thread back to OCaml thread.
            // In OCaml thread will be [POINT C, POINT C ALTERNATE]
            post(OCamlServiceHandler::stop_ocaml);
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
