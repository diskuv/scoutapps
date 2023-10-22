package com.example.squirrelscout_scouter;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;

import androidx.core.os.HandlerCompat;

public class MainApplication extends Application {
    private final Handler uiThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper());

    public Handler getUiThreadHandler() {
        return uiThreadHandler;
    }
}
