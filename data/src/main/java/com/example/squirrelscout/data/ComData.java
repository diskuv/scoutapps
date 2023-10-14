package com.example.squirrelscout.data;

import android.content.Context;

import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroid;
import com.diskuv.dksdk.ffi.java.compat.JavaJdkCompat;
import com.example.squirrelscout.data.objects.Calculations;
import com.example.squirrelscout.data.objects.Multiply;

public class ComData {
    private static Com COM;
    private static JavaJdkCompat COMPAT;
    private final JavaJdkCompat compat;
    private final Multiply multiply;
    private final Calculations calculations;

    public static synchronized void initialize(Context context) {
        if(COMPAT == null || COM == null) {
            COMPAT = JavaJdkCompatAndroid.createWithDkSDK("datalib");
            COM = Com.createForProduction(COMPAT);
        }
    }

    public static synchronized ComData getInstance(Context context) {
        return new ComData(COMPAT, COM);
    }

    private ComData(JavaJdkCompat compat, Com com) {
        this.compat = compat;
        this.multiply = Multiply.create(com);
        this.calculations = Calculations.create(com);
    }

    public Multiply getMultiply() {
        return multiply;
    }

    public Calculations getCalculations() {
        return calculations;
    }
}
