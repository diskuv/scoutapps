package com.example.squirrelscout_scouter.ui.stack;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.activity.ComponentActivity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelStoreOwner;

/**
 * The clean way to support the accumulation of Scouting information
 * is through a {@link androidx.lifecycle.ViewModel}. The ViewModel
 * would be scoped to a {@link androidx.navigation.NavBackStackEntry} so it is
 * associated with the Navigation of the "Start Scouting". Confer
 * <a href="https://developer.android.com/topic/libraries/architecture/viewmodel#scope">ViewModel scope</a>.
 * <p>
 * However Squirrel Scout does not currently use Navigation. Instead it does
 * it own {@link android.app.Activity#startActivity(android.content.Intent)}
 * calls. (Note: The manual calls are somewhat buggy because it does not implement the
 * Back button correctly. Use
 * <a href="https://developer.android.com/guide/navigation/migrate">Migrate to the Navigation component</a>
 * to fix this).
 * <p>
 * What that means is that the ViewModel can only be scoped to an activity.
 * For the "Start Scouting" scope, we can use the "bottom-most" StartScoutingActivity (the
 * first created, still-running StartScoutingActivity) as the scope. That way all sub-activities
 * of StartScouting shared the same scouting data.
 * <p>
 * And at some later date when Navigation gets introduced the ViewModel won't need any changes.
 */
public class BottomViewModelStoreOwnerFinder implements Application.ActivityLifecycleCallbacks {
    public interface ComponentActivityMatcher {
        boolean matches(ComponentActivity activity);
    }

    private final ComponentActivityMatcher matcher;

    /**
     * How many [StartScoutingActivity] there are currently in the Activity stack
     */
    private int numberOfMatchesInActivityStack;

    private ViewModelStoreOwner bottomViewModelStoreOwner;

    public BottomViewModelStoreOwnerFinder(ComponentActivityMatcher matcher) {
        this.matcher = matcher;
    }

    /**
     * The ViewModelStore for the bottom-most [StartScoutingActivity] in the Activity stack.
     * That is, get the ViewModelStore for the first-created activity of the still-running
     * activities that matches the search parameters.
     *
     * @return may be null
     */
    public ViewModelStoreOwner getBottomViewModelStoreOwner() {
        return bottomViewModelStoreOwner;
    }

    private ComponentActivity matches(@NonNull Activity activity) {
        if (!(activity instanceof ComponentActivity)) return null;
        ComponentActivity componentActivity = (ComponentActivity) activity;
        if (matcher.matches(componentActivity)) {
            return componentActivity;
        }
        return null;
    }

    /** onActivityCreated HAPPENS-BEFORE Activity.onCreate(), so inside
     * Activity.onCreate() you can use the <code>bottomViewModelStoreOwner</code> */
    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
        ComponentActivity componentActivity = matches(activity);
        if (componentActivity == null) return;

        if (numberOfMatchesInActivityStack == 0) {
            bottomViewModelStoreOwner = componentActivity;
        }
        ++numberOfMatchesInActivityStack;
    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {

    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {

    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {

    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {
        ComponentActivity componentActivity = matches(activity);
        if (componentActivity == null) return;

        --numberOfMatchesInActivityStack;
        if (numberOfMatchesInActivityStack == 0) {
            bottomViewModelStoreOwner = null;
        }
    }
}
