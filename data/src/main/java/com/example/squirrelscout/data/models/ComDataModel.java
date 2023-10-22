package com.example.squirrelscout.data.models;

import android.content.Context;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.objects.ScoutDatabase;
import com.example.squirrelscout.data.objects.ScoutQR;

/**
 * Class and instance objects for the data layer defined as COM objects.
 */
public class ComDataModel {
    private final ScoutDatabase scoutDatabase;
    private final ScoutQR scoutQR;

    public ComDataModel(Com com, Context context) {
        this.scoutDatabase = ScoutDatabase.create(com, context);
        this.scoutQR = ScoutQR.create(com);
    }

    public ScoutDatabase getScoutDatabase() {
        return scoutDatabase;
    }

    public ScoutQR getScoutQR() {
        return scoutQR;
    }
}
