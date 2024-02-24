package com.example.squirrelscout_scouter.util;

public class ScoutSingleton {
    private static ScoutSingleton instance;
    private static int matchNum, robotNum;
    private static String robotColor;

    public static synchronized ScoutSingleton getInstance(){
        if(instance == null){
            instance = new ScoutSingleton();
            matchNum = -1;
            robotColor = "";
            robotNum = -1;

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

    public String getRobotColor(){ return robotColor; }

    public void setRobotColor(String color) { robotColor = color; }
}
