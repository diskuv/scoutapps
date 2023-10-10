package com.example.squirrelscout.data;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.startup.Initializer;

import java.util.Collections;
import java.util.List;

public class ComDataInitializer implements Initializer<ComData> {
    @NonNull
    @Override
    public ComData create(@NonNull Context context) {
        ComData.initialize(context);
        return ComData.getInstance(context);
    }

    @NonNull
    @Override
    public List<Class<? extends Initializer<?>>> dependencies() {
        return Collections.emptyList();
    }

}
