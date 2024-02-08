package com.example.squirrelscout_scouter.util;

import android.app.Application;
import android.graphics.Bitmap;
import android.view.MotionEvent;
import android.widget.ImageView;
import android.view.MotionEvent;

import java.util.ArrayList;
import java.util.BitSet;

public class SharedImageSingleton extends Application {
    private static SharedImageSingleton instance;
    Bitmap markedImage;
    int scored, success, miss;

    public static synchronized SharedImageSingleton getInstance() {
        if (instance == null) {
            instance = new SharedImageSingleton();
        }
        return instance;
    }

    public Bitmap getMarkedImage() {
        return markedImage;
    }

    public void setMarkedImage(Bitmap image) {
        markedImage = image;
    }

    public int getScored(){
        return scored;
    }

    public void setScored(int s){
        scored = s;
    }

    public void setSuccess(){
        success++;
    }

    public int getSuccess(){
        return success;
    }

    public void setMiss(){
        miss++;
    }

    public int getMiss(){
        return miss;
    }
}
