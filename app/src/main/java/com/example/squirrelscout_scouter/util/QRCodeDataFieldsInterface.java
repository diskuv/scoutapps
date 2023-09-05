package com.example.squirrelscout_scouter.util;

public interface QRCodeDataFieldsInterface {

    //start scouting and robot scouting data points
    public void setScoutName(String name);
    public String getScoutName();
    public void setScoutTeam(int scoutsTeam);
    public int getScoutTeam();
    public void setScoutMatch(int scoutMatch);
    public int getScoutMatch();
    public void setRobotPosition(String robotPosition);
    public String getRobotPosition();
    public int getRobotScouting();
    public void setRobotScouting(int robot);

    //autonomous data points
    public void setLowConeAuto(int cone);
    public int getLowConeAuto();
    public void setMidConeAuto(int cone);
    public int getMidConeAuto();
    public void setHighConeAuto(int cone);
    public int getHighConeAuto();
    public void setLowCubeAuto(int cube);
    public int getLowCubeAuto();
    public void setMidCubeAuto(int cube);
    public int getMidCubeAuto();
    public void setHighCubeAuto(int cube);
    public int getHighCubeAuto();
    public void setMobility(boolean mobility);
    public Boolean getMobility();
    public void setAutoClimb(String climb);
    public String getAutoClimb();

    //teleop scouting data points
    public void setLowConeTele(int cone);
    public int getLowConeTele();
    public void setMidConeTele(int cone);
    public int getMidConeTele();
    public void setHighConeTele(int cone);
    public int getHighConeTele();
    public void setLowCubeTele(int cube);
    public int getLowCubeTele();
    public void setMidCubeTele(int cube);
    public int getMidCubeTele();
    public void setHighCubeTele(int cube);
    public int getHighCubeTele();
    public void setDefense(boolean defense);
    public boolean getDefense();
    public void setIncap(boolean incap);
    public boolean getIncap();
    public void setTeleClimb(String climb);
    public String getTeleClimb();
    public void setNotes(String note);
    public String getNotes();
}
