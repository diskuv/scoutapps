@0xff041fa19d4b5a6f;

# This section is used by capnproto-java only
using Java = import "/capnp/java.capnp";
$Java.package("com.example.squirrelscout.data.capnp");
$Java.outerClassname("Schema");

#2024 testing
struct RawMatchData {
  # generic data 
  teamNumber @0 :Int16;
  teamName @1 :Text;
  matchNumber @2 :Int16;
  scouterName @3 :Text;
  allianceColor @4 :RobotPosition;

  # game specific | auto 
  startingPosition @5 :SPosition;
  wingNote1 @6 : Bool;
  wingNote2 @7 : Bool;
  wingNote3 @8 : Bool;
  centerNote1 @9 : Bool;
  centerNote2 @10 : Bool;
  centerNote3 @11 : Bool;
  centerNote4 @12 : Bool;
  centerNote5 @13 : Bool;
  autoAmpScore @14 : Int16;
  autoAmpMiss @15 : Int16;
  autoSpeakerScore @16 : Int16;
  autoSpeakerMiss @17 : Int16;
  autoLeave @18 : Bool;

  # game specific  teleop
  teleSpeakerScore @19 : Int16;
  teleSpeakerMiss @20 : Int16;
  teleAmpScore @21 : Int16;
  teleAmpMiss @22 : Int16;
  distance @23 : Text;
  teleBreakdown @24: TBreakdown;
  telePickup @25: Text;
  endgameClimb @26 : EClimb;
  endgameTrap @27 : Bool;  
}

enum SPosition{
  ampSide @0;
  center @1;
  sourceSide @2;
}

enum TBreakdown{
  none @0;
  tipped @1;
  mechanicalFailure @2;
  incapacitated @3;
}

enum EClimb{
  success @0;
  failed @1;
  didNotAttempt @2;
  harmony @3;
  park @4;
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
