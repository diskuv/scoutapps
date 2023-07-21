package com.example.squirrelscout_scouter.util;

public class ScoutedData implements QRCodeDataFieldsInterface{
    private static ScoutedData instance = null;


    private boolean autoMobility = false;
    private ScoutedData() {

    }


    public static ScoutedData getInstance() {
        if(instance == null) {
            return new ScoutedData();
        }

        return instance;
    }

    @Override
    public void setAutoMobility(Boolean value) {
        this.autoMobility = value;
    }

    @Override
    public boolean getAutoMobility() {
        return autoMobility;
    }

    @Override
    public void generateQRCode() {

    }
}
