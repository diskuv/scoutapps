package com.example.squirrelscout.data;

public class NativeLib {

    // Used to load the 'datalib' library on application startup.
    static {
        System.loadLibrary("datalib");
    }

    /**
     * A native method that is implemented by the 'data' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}