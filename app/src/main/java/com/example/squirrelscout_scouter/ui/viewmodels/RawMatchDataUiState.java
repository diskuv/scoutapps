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
public abstract class RawMatchDataUiState {

    public abstract String scoutName();

    public abstract String positionScouting();

    public abstract String autoClimb();

    public abstract String teleClimb();

    public abstract String notes();

    public abstract int scoutTeam();

    public abstract int matchScouting();

    public abstract int robotScouting();

    public abstract int coneHighA();

    public abstract int coneMidA();

    public abstract int coneLowA();

    public abstract int cubeHighA();

    public abstract int cubeMidA();

    public abstract int cubeLowA();

    public abstract int coneHighT();

    public abstract int coneMidT();

    public abstract int coneLowT();

    public abstract int cubeHighT();

    public abstract int cubeMidT();

    public abstract int cubeLowT();

    public abstract boolean mobility();

    public abstract boolean defense();

    public abstract boolean incapacitated();
}
