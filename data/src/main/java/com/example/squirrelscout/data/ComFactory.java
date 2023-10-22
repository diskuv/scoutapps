package com.example.squirrelscout.data;

import android.content.Intent;

import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroid;
import com.diskuv.dksdk.ffi.java.compat.JavaJdkCompat;

import java.util.logging.Level;

public class ComFactory {
    enum ComDomain {
        PRODUCTION,
        PRODUCTION_TEST
    }

    static Com createDataForeground(Intent intent, ComDomain comDomain) {
        String logName = intent.getStringExtra("Com.logName");

        final JavaJdkCompat compat = JavaJdkCompatAndroid.createWithDkSDK("data_foreground");

        // Initialize Android logging
        compat.getCLib().dksdk_ffi_c_log_configure_android(logName == null ? "DataForeground" : logName, Level.FINEST);

        // Do dksdk_ffi_host_create() and standard DkSDK FFI C + Java class object registrations
        return comDomain == ComDomain.PRODUCTION_TEST ? Com.createForProductionTesting(compat) : Com.createForProduction(compat);
    }
}
