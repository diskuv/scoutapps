@0xff041fa19d4b5a6f;

struct Person {
  num @0 :Int16;
}

struct RawMatchData {
  # generic data 
  teamNumber @0 :Int16;
  teamName @1 :Text;
  matchNumber @2 :Int16;
  scouterName @3 :Text;

  # game specific | auto 
  autoMobility @4 :Bool;
  autoClimb @5 :Climb;
  autoConeHigh @6 :Int16;
  autoConeMid @7 :Int16;
  autoConeLow @8 :Int16;
  autoCubeHigh @9 :Int16;
  autoCubeMid @10 :Int16;
  autoCubeLow @11 :Int16;


  # game specific  teleop
  teleClimb @12 :Climb;
  teleConeHigh @13 :Int16;
  teleConeMid @14 :Int16;
  teleConeLow @15 :Int16;
  teleCubeHigh @16 :Int16;
  teleCubeMid @17 :Int16;
  teleCubeLow @18 :Int16;

  # misc 
  incap @19 :Bool;
  playingDefense @20 :Bool;
  notes @21 :Text;
}

enum Climb {
  none @0;
  docked @1;
  engaged @2;
}