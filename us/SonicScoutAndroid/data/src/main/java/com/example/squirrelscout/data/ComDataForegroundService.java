package com.example.squirrelscout.data;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.os.Message;

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
    private static OCamlServiceHandler ocamlHandler;
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

    protected boolean hasProductionTestObjects() {
        return false;
    }

    protected String getLogName() {
        return null;
    }

    @Override
    public void onCreate() {
        synchronized (ComDataForegroundService.class) {
            if (ocamlHandler == null) {
                ComFactory.ComDomain comDomain = hasProductionTestObjects() ?
                        ComFactory.ComDomain.PRODUCTION_TEST : ComFactory.ComDomain.PRODUCTION;
                ocamlHandler = OCamlServiceHandler.create(
                        getLogName(), getPackageName(), comDomain);
            }
        }

        ocamlHandler.updateActiveForegroundService(getApplicationContext());

        // Send INIT message which will do POINT B
        Message msg = ocamlHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_INIT.ordinal();
        ocamlHandler.sendMessage(msg);
    }

    public void requestData(ComDataRequestCallback callback) {
        // Posting to the service thread makes sure the first service
        // thread message (start OCaml) has been completed.
        //
        // Also, being in the service thread means we don't have to
        // work about whether OCaml has been registered in the thread
        // if the data accessed needs to call back into OCaml.
        ocamlHandler.post(() -> {
            ComDataModel data0 = ocamlHandler.getData();
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
        Message msg = ocamlHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_START.ordinal();
        ocamlHandler.sendMessage(msg);

        return binder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        // Send STOP message which will undo POINT D + C
        Message msg = ocamlHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_STOP.ordinal();
        ocamlHandler.sendMessage(msg);

        /* Do not call onRebind() when a new bind comes in */
        return false;
    }

    @Override
    public void onDestroy() {
        // Send DESTROY message which will undo POINT B ALTERNATE
        Message msg = ocamlHandler.obtainMessage();
        msg.arg1 = HandlerMessageType.MSG_DESTROY.ordinal();
        ocamlHandler.sendMessage(msg);
    }
}