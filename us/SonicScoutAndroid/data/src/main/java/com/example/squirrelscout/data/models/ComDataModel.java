package com.example.squirrelscout.data.models;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.objects.ScoutDatabase;
import com.example.squirrelscout.data.objects.ScoutQR;

/**
 * Class and instance objects for the data layer defined as COM objects.
 */
public class ComDataModel implements LifecycleOwner {
    public interface LifecycleRegistrySetter {
        void setLifecycleRegistry(LifecycleRegistry registry);
    }
    private final LifecycleRegistry lifecycleRegistry;
    private final ScoutDatabase scoutDatabase;
    private final ScoutQR scoutQR;

    public ComDataModel(Com com, Context context, LifecycleRegistrySetter lifecycleRegistrySetter) {
        this.lifecycleRegistry = new LifecycleRegistry(this);
        this.scoutDatabase = ScoutDatabase.create(com, context);
        this.scoutQR = ScoutQR.create(com);
        lifecycleRegistrySetter.setLifecycleRegistry(lifecycleRegistry);
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }
    public ScoutDatabase getScoutDatabase() {
        return scoutDatabase;
    }

    public ScoutQR getScoutQR() {
        return scoutQR;
    }
}
