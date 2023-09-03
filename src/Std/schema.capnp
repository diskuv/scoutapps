@0xff041fa19d4b5a6f;

struct RawMatchData {
  # generic data 
  teamNumber @0 :Int16;
  teamName @1 :Text;
  matchNumber @2 :Int16;
  scouterName @3 :Text;

  # misc 
  incap @4 :Bool;
  playingDefense @5 :Bool;
  notes @6 :Text;

  # game specific | auto 
  autoMobility @7 :Bool;
  autoClimb @8 :Climb;
  autoConeHigh @9 :Int16;
  autoConeMid @10 :Int16;
  autoConeLow @11 :Int16;
  autoCubeHigh @12 :Int16;
  autoCubeMid @13 :Int16;
  autoCubeLow @14 :Int16;


  # game specific  teleop
  teleClimb @15 :Climb;
  teleConeHigh @16 :Int16;
  teleConeMid @17 :Int16;
  teleConeLow @18 :Int16;
  teleCubeHigh @19 :Int16;
  teleCubeMid @20 :Int16;
  teleCubeLow @21 :Int16;

  
}

enum Climb {
  none @0;
  docked @1;
  engaged @2;
}