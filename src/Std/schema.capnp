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

  # game specific | auto 
  startingPosition @4 :SPosition;
  wingNote1 @5 : Bool;
  wingNote2 @6 : Bool;
  wingNote3 @7 : Bool;
  centerNote1 @8 : Bool;
  centerNote2 @9 : Bool;
  centerNote3 @10 : Bool;
  centerNote4 @11 : Bool;
  centerNote5 @12 : Bool;
  autoAmpScore @13 : Int16;
  autoAmpMiss @14 : Int16;
  autoSpeakerScore @15 : Int16;
  autoSpeakerMiss @16 : Int16;
  autoLeave @17 : Bool;

  # game specific  teleop
  teleSpeakerScore @18 : Int16;
  teleSpeakerMiss @19 : Int16;
  teleAmpScore @20 : Int16;
  teleAmpMiss @21 : Int16;
  teleBreakdown @22: TBreakdown;
  endgamePark @23 : Bool;
  endgameClimb @24 : EClimb;
  endgameTrap @25 : Bool;

  
}

enum SPosition{
  left @0;
  center @1;
  right @2;
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
