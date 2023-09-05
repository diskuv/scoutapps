package com.example.squirrelscout_scouter;

import com.example.squirrelscout_scouter.util.QRCodeDataFieldsInterface;

//singleton class to hold all the scout info
public class ScoutInfo implements QRCodeDataFieldsInterface {
    //static variable of a single object
    private static  ScoutInfo single_instance = null;

    //variables
    private String scoutName, positionScouting, autoClimb, teleClimb, notes;
    private int scoutTeam, matchScouting, robotScouting;
    private int coneHighA, coneMidA, coneLowA, cubeHighA, cubeMidA, cubeLowA, coneHighT, coneMidT, coneLowT, cubeHighT, cubeMidT, cubeLowT;
    private boolean mobility, defense, incapacitated;


    //constructor
    private ScoutInfo(){
        //blank settings
        scoutName = null;
        scoutTeam = -1;
        matchScouting = -1;
        positionScouting = null;
        robotScouting = -1;
        //points
        coneHighA = -1;
        coneMidA = -1;
        coneLowA = -1;
        cubeHighA = -1;
        cubeLowA = -1;
        cubeMidA = -1;
        coneHighT = -1;
        coneMidT = -1;
        coneLowT = -1;
        cubeHighT = -1;
        cubeLowT = -1;
        cubeMidT = -1;
        //...
        mobility = false;
        autoClimb = null;
        incapacitated = false;
        defense = false;
        teleClimb = null;
        notes = "";

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
    public void setRobotScouting(int robot) { robotScouting = robot; }
    @Override
    public int getRobotScouting() { return robotScouting; }
    @Override
    public void setLowConeAuto(int cone) { coneLowA = cone; }
    @Override
    public int getLowConeAuto() {
        return coneLowA;
    }
    @Override
    public void setMidConeAuto(int cone) { coneMidA = cone; }
    @Override
    public int getMidConeAuto() {
        return coneMidA;
    }
    @Override
    public void setHighConeAuto(int cone) { coneHighA = cone; }
    @Override
    public int getHighConeAuto() {
        return coneHighA;
    }
    @Override
    public void setLowCubeAuto(int cube) { cubeLowA = cube; }
    @Override
    public int getLowCubeAuto() {
        return cubeLowA;
    }
    @Override
    public void setMidCubeAuto(int cube) { cubeMidA = cube; }
    @Override
    public int getMidCubeAuto() { return cubeMidA; }
    @Override
    public void setHighCubeAuto(int cube) { cubeHighA = cube; }
    @Override
    public int getHighCubeAuto() {
        return cubeHighA;
    }
    @Override
    public void setMobility(boolean m) { mobility = m; }
    @Override
    public Boolean getMobility() {
        return mobility;
    }
    @Override
    public void setAutoClimb(String climb) { autoClimb = climb; }
    @Override
    public String getAutoClimb() {
        return autoClimb;
    }
    @Override
    public void setLowConeTele(int cone) { coneLowT = cone; }
    @Override
    public int getLowConeTele() {
        return coneLowT;
    }
    @Override
    public void setMidConeTele(int cone) { coneMidT = cone; }
    @Override
    public int getMidConeTele() {
        return coneMidT;
    }
    @Override
    public void setHighConeTele(int cone) { coneHighT = cone; }
    @Override
    public int getHighConeTele() {
        return coneHighT;
    }
    @Override
    public void setLowCubeTele(int cube) { cubeLowT = cube; }
    @Override
    public int getLowCubeTele() {
        return cubeLowT;
    }
    @Override
    public void setMidCubeTele(int cube) { cubeMidT = cube; }
    @Override
    public int getMidCubeTele() { return cubeMidT; }
    @Override
    public void setHighCubeTele(int cube) { cubeHighT = cube; }
    @Override
    public int getHighCubeTele() { return cubeHighT; }
    @Override
    public void setDefense(boolean defense) { this.defense = defense; }
    @Override
    public boolean getDefense() { return defense; }
    @Override
    public void setIncap(boolean incap) { incapacitated = incap; }
    @Override
    public boolean getIncap() { return incapacitated; }
    @Override
    public void setTeleClimb(String climb) { teleClimb = climb; }
    @Override
    public String getTeleClimb() { return teleClimb; }
    @Override
    public void setNotes(String note){ notes = note; }
    @Override
    public String getNotes(){ return notes; }
}
