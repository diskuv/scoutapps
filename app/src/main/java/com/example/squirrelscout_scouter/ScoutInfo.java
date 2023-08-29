package com.example.squirrelscout_scouter;

import com.example.squirrelscout_scouter.util.QRCodeDataFieldsInterface;

//singleton class to hold all the scout info
public class ScoutInfo implements QRCodeDataFieldsInterface {
    //static variable of a single object
    private static  ScoutInfo single_instance = null;

    //variables
    private String scoutName, positionScouting;
    private int scoutTeam, matchScouting;

    //constructor
    private ScoutInfo(){
        //blank settings
        scoutName = null;
        scoutTeam = -1;
        matchScouting = -1;
        positionScouting = null;
    }

    //static method to create instance of com.example.squirrelscout_scouter.ScoutInfo class
    public static synchronized ScoutInfo getInstance(){
        if(single_instance == null){
            single_instance = new ScoutInfo();
        }
        return single_instance;
    }

    @Override
    public void setScoutName(String name) { scoutName = name; }
    @Override
    public String getScoutName() { return scoutName; }
    @Override
    public void setScoutTeam(int scoutsTeam) { scoutTeam = scoutsTeam; }
    @Override
    public int getScoutTeam() { return scoutTeam; }
    @Override
    public void setScoutMatch(int scoutMatch) { matchScouting = scoutMatch; }
    @Override
    public int getScoutMatch() { return matchScouting; }
    @Override
    public void setRobotPosition(String robotPosition) { positionScouting = robotPosition; }
    @Override
    public String getRobotPosition() { return positionScouting; }
}
