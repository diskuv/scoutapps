package com.example.squirrelscout_scouter.ui.viewmodels;

import org.immutables.value.Value;

/**
 * The UI state for raw match data obtained during a scouting session.
 *
 * It can be made immutable (a requirement for Android UI state) and
 * has the good Java citizen behaviors like proper equals/hashCode (with
 * the immutable) and can be converted to/from Capn' Proto (which is
 * part of the "data" layer model object).
 */
@Value.Immutable
@Value.Modifiable
public interface RawMatchDataUiState {

    String scoutName();

    String positionScouting();

    //delete later
    String autoClimb();

    String teleClimb();

    String notes();

    int matchScouting();

    int robotScouting();

    int coneHighA();

    int coneMidA();

    int coneLowA();

    int cubeHighA();

    int cubeMidA();

    int cubeLowA();

    int coneHighT();

    int coneMidT();

    int coneLowT();

    int cubeHighT();

    int cubeMidT();

    int cubeLowT();

    boolean mobility();

    boolean defense();

    boolean incapacitated();


    //auto
    String startingPosition();
    boolean wingNote1();
    boolean wingNote2();
    boolean wingNote3();
    boolean centerNote1();
    boolean centerNote2();
    boolean centerNote3();
    boolean centerNote4();
    boolean centerNote5();
    int autoAmpScore();
    int autoAmpMiss();
    int autoSpeakerScore();
    int autoSpeakerMiss();
    boolean autoLeave();

    //teleop
    int teleSpeakerScore();
    int teleSpeakerMiss();
    int teleAmpScore();
    int teleAmpMiss();
    String teleBreakdown();
    boolean endgamePark();
    String endgameClimb();
    boolean endgameTrap();
}
