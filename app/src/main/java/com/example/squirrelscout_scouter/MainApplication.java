package com.example.squirrelscout_scouter;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;

import androidx.core.os.HandlerCompat;
import androidx.lifecycle.ViewModelStoreOwner;

import com.example.squirrelscout_scouter.match_scouting_pages.StartScoutingActivity;
import com.example.squirrelscout_scouter.ui.stack.BottomViewModelStoreOwnerFinder;

public class MainApplication extends Application {
    /*  DEPENDENCY INJECTION
        --------------------

        These [final] fields are a form of "Manual Dependency Injection" described at
        https://developer.android.com/training/dependency-injection/manual */

    private final Handler uiThreadHandler = HandlerCompat.createAsync(Looper.getMainLooper());
    private final BottomViewModelStoreOwnerFinder scoutingSessionViewModelStoreOwnerFinder =
            new BottomViewModelStoreOwnerFinder(activity -> activity instanceof StartScoutingActivity);

    public Handler getUiThreadHandler() {
        return uiThreadHandler;
    }

    public ViewModelStoreOwner getScoutingSessionViewModelStoreOwner() {
        return scoutingSessionViewModelStoreOwnerFinder.getBottomViewModelStoreOwner();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        registerActivityLifecycleCallbacks(scoutingSessionViewModelStoreOwnerFinder);
    }
}
