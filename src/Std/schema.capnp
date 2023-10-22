@0xff041fa19d4b5a6f;

# This section is used by capnproto-java only
using Java = import "/capnp/java.capnp";
$Java.package("com.example.squirrelscout.data.capnp");
$Java.outerClassname("Schema");

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

enum RobotPosition {
  red1 @0;
  red2 @1;
  red3 @2;
  blue1 @3;
  blue2 @4;
  blue3 @5; 
}

struct MatchAndPosition {
  match @0 :Int16;
  position @1 :RobotPosition;
}

struct MaybeError {
  success @0: Bool;
  messageIfError @1 :Text;
}
