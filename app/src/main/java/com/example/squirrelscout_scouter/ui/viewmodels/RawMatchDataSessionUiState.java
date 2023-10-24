package com.example.squirrelscout_scouter.ui.viewmodels;

import org.immutables.value.Value;

@Value.Immutable
public interface RawMatchDataSessionUiState {
    /** Tracks which session number started the modifications to the raw match data. */
    long sessionNumber();

    /** The current (possibly partial) state of the raw match data */
    ModifiableRawMatchDataUiState modifiableRawMatchData();
}
