package com.example.squirrelscout.data;

import static android.content.Context.BIND_AUTO_CREATE;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

/**
 * An observer that gives access to OCaml COM data while the application
 * is in the foreground.
 * <p>
 * When the application is in the background, the OCaml thread defined
 * in the shared library <code>data_foreground</code> may shutdown
 * and only restart when the application comes back to the foreground.
 * As such, no background tasks like fetching a long stream of updates
 * from a server should ever be in <code>data_foreground</code>
 * <p>
 * Future: Use a different shared library <code>data_background</code>
 * for long-running tasks that work together with a WorkManager.
 */
public class ComDataForegroundListener implements DefaultLifecycleObserver {
    private final Context context;
    private final ComDataRequestCallback callback;

    private ComDataForegroundListener(Context context, ComDataRequestCallback callback) {
        this.context = context;
        this.callback = callback;
    }

    public static void listen(Context context, Lifecycle lifecycle, ComDataRequestCallback callback) {
        // https://developer.android.com/topic/libraries/architecture/lifecycle
        ComDataForegroundListener listener = new ComDataForegroundListener(context, callback);
        lifecycle.addObserver(listener);
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
        context.bindService(new Intent(context, ComDataForegroundService.class), dataConnection, BIND_AUTO_CREATE);
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
        context.unbindService(dataConnection);
    }

    private final ServiceConnection dataConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            ComDataForegroundService foregroundService = ((ComDataForegroundService.ComDataBinder) service).getService();
            foregroundService.requestData(callback);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
        }
    };
}
