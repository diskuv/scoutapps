package com.example.squirrelscout.data;

import android.content.Context;
import android.content.res.AssetManager;

import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroid;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroidLoader;
import com.diskuv.dksdk.ffi.java.compat.JavaJdkCompat;
import com.diskuv.dksdk.ffi.java.jn.DksdkFfiC;
import com.example.squirrelscout.data.objects.Calculations;
import com.example.squirrelscout.data.objects.Multiply;
import com.kenai.jffi.internal.StubLoader;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Locale;

public class ComData {
    private static final boolean MODERN = true;
    private static Com COM;
    private static JavaJdkCompat COMPAT;
    private final JavaJdkCompat compat;
    private final Multiply multiply;
    private final Calculations calculations;

    public static synchronized void initialize(Context context) {
        if(COMPAT == null || COM == null) {
            DksdkFfiC.Lib lib = MODERN ? loadLibraryFromAar("datalib") : loadLibraryFromAssets(context.getAssets(), "datalib");
            COMPAT = new JavaJdkCompatAndroid(lib);
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

    private static DksdkFfiC.Lib loadLibraryFromAar(String libraryName) {
        /* Load the JNR native library from the com.diskuv.dkml.jnr:jffi-native-android AAR.
           This is not supported by JNR today so StubLoader's static initializer will complain
           but we'll patch it up. */
        String jffiLib = String.format(Locale.ENGLISH, "jffi-%d.%d",
                com.kenai.jffi.internal.StubLoader.VERSION_MAJOR,
                com.kenai.jffi.internal.StubLoader.VERSION_MINOR);
        System.loadLibrary(jffiLib);

        try {
            /* [patch] StubLoader.loaded = true; */
            Field loadedField = com.kenai.jffi.internal.StubLoader.class.getDeclaredField("loaded");
            loadedField.setAccessible(true);
            loadedField.set(com.kenai.jffi.internal.StubLoader.class, true);
        } catch (NoSuchFieldException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }

        /* Android does not support bytecode class loading.
         * Confer: https://developer.android.com/training/articles/perf-jni.html#unsupported-featuresbackwards-compatibility */
        System.setProperty("jnr.ffi.asm.enabled", "false");

        return JavaJdkCompatAndroidLoader.loadDualJniAndJnrLibrary(libraryName);
    }

    // TODO: Move into ffi-java-android module.
    private static DksdkFfiC.Lib loadLibraryFromAssets(AssetManager assetManager, String libraryName) {
        ClassLoader originalClassLoader = Thread.currentThread().getContextClassLoader();
        try {
            class AssetClassLoader extends ClassLoader {
                AssetClassLoader() {
                    super(originalClassLoader);
                }
                @Override
                public InputStream getResourceAsStream(String name) {
                    try {
                        return assetManager.open(name);
                    } catch (IOException e) {
                        return null; /* not found */
                    }
                }
            }

            Thread.currentThread().setContextClassLoader(new AssetClassLoader());
            return JavaJdkCompatAndroidLoader.loadDualJniAndJnrLibrary(libraryName);
        } finally {
            Thread.currentThread().setContextClassLoader(originalClassLoader);
        }
    }
}
