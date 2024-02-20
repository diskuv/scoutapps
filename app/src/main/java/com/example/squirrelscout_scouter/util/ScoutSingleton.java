package com.example.squirrelscout_scouter.util;

public class ScoutSingleton {
    private static ScoutSingleton instance;
    private int matchNum, robotNum;

    public static synchronized ScoutSingleton getInstance(){
        if(instance == null){
            instance = new ScoutSingleton();
        }
        return instance;
    }

    public int getMatchNum(){
        return matchNum;
    }

    public void setMatchNum(int a){
        matchNum = a;
    }

    public int getRobotNum(){
        return robotNum;
    }

    public void setRobotNum(int a){
        robotNum = a;
    }
}
