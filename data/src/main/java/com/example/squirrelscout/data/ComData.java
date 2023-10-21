package com.example.squirrelscout.data;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroid;
import com.diskuv.dksdk.ffi.java.compat.JavaJdkCompat;
import com.example.squirrelscout.data.objects.ScoutBridge;
import com.example.squirrelscout.data.objects.toy.Calculations;
import com.example.squirrelscout.data.objects.toy.Multiply;
import com.example.squirrelscout.data.objects.toy.Add1;

import java.util.logging.Level;

public class ComData {
    private static JavaJdkCompat G_COMPAT;
    private final Com com;
    private final Add1 add1;
    private final Multiply multiply;
    private final Calculations calculations;
    private final ScoutBridge scoutBridge;

    static Com newCom(Intent intent) {
        boolean test = intent.getBooleanExtra("ComData.productionTest", false);
        String logName = intent.getStringExtra("ComData.logName");

        final JavaJdkCompat compat = getOrCreateJavaJdkCompat();

        // Initialize Android logging
        compat.getCLib().dksdk_ffi_c_log_configure_android(logName == null ? "ComData" : logName, Level.FINEST);

        // Do dksdk_ffi_host_create() and standard DkSDK FFI C + Java class object registrations
        return test ? Com.createForProductionTesting(compat) : Com.createForProduction(compat);
    }

    @NonNull
    private static JavaJdkCompat getOrCreateJavaJdkCompat() {
        synchronized (ComData.class) {
            if (G_COMPAT == null) {
                G_COMPAT = JavaJdkCompatAndroid.createWithDkSDK("datalib");
            }
            return G_COMPAT;
        }
    }

    ComData(Com com) {
        this.com = com;
        this.multiply = Multiply.create(com);
        this.add1 = Add1.create(com);
        this.calculations = Calculations.create(com);
        this.scoutBridge = ScoutBridge.create(com);
    }

    protected synchronized void shutdown() {
        com.shutdown();
    }

    public Add1 getAdd1() {
        return add1;
    }

    public Multiply getMultiply() {
        return multiply;
    }

    public Calculations getCalculations() {
        return calculations;
    }

    public ScoutBridge getScoutBridge() {
        return scoutBridge;
    }
}
