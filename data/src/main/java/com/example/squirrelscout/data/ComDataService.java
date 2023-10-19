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

/**
 * DkSDK use a Service because it needs:
 *
 * <ol>
 * <li>The ability to shutdown (remove registrations).</li>
 * <li>The ability to spawn a background thread that runs the
 * OCaml code and will be tracked by Android, and stopped if Android
 * needs the memory.</li>
 * </ol>
 * <p>
 * Because the OCaml service background thread can be stopped,
 * anything transient memory inside OCaml will be lost. This is
 * a "data" layer after all!
 * <p>
 * Additionally, starting up OCaml should not take long since it
 * will impact the user when the app comes to the foreground after
 * Android had stopped the thread earlier.
 */
public class ComDataService extends Service {
    private static native void initializeOCamlRuntime(String processArg0);
    private static native void asyncStopOCaml();

    private ComData data;
    private ComDataHandler serviceHandler;
    private final IBinder binder = new ComDataBinder();

    public final class ComDataBinder extends Binder {
        public ComDataService getService() {
            return ComDataService.this;
        }
    }

    // Handler that receives messages from the thread
    private final class ComDataHandler extends Handler {
        private boolean initted;

        public ComDataHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            // Only do OCaml initialization once
            synchronized (ComDataService.class) {
                if (initted) return;
                initted = true;
            }

            // Initialize the OCaml code, which will run all the
            // top-level `let () =` statements as well.
            initializeOCamlRuntime(getPackageName());
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

    public ComData getData() {
        return data;
    }

    @Override
    public IBinder onBind(Intent intent) {
        Toast.makeText(this, "COM data service bound", Toast.LENGTH_SHORT).show();

        // For the first bind request, do dksdk_ffi_init() plus C registrations
        data = ComData.newDataInstance(intent);

        // For the first bind request, send a message to initialize the
        // OCaml runtime, initialize DkSDK FFI OCaml, and register user objects.
        Message msg = serviceHandler.obtainMessage();
        serviceHandler.sendMessage(msg);

        return binder;
    }

    @Override
    public void onDestroy() {
        Toast.makeText(this, "COM data service done", Toast.LENGTH_SHORT).show();

        // Should perform OCaml FFI deregistrations
        asyncStopOCaml();

        // Completely shuts down with C deregistrations + dksdk_ffi_terminate()
        data.shutdown();
    }
}