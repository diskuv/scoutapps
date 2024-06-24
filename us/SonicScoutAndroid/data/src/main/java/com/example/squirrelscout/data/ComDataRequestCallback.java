package com.example.squirrelscout.data;

import com.example.squirrelscout.data.models.ComDataModel;

/**
 * A callback for when the {@link ComDataModel} is ready.
 */
public interface ComDataRequestCallback {
    void onComDataReady(ComDataModel data);
}
