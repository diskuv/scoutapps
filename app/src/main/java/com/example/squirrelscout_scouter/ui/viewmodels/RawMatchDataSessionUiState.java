package com.example.squirrelscout_scouter.ui.viewmodels;

import org.immutables.value.Value;

@Value.Immutable
public interface RawMatchDataSessionUiState extends WithRawMatchDataSessionUiState {
    /**
     * Tracks which session number started the modifications to the raw match data.
     */
    long sessionNumber();

    /**
     * Monotonically increases every modification to the raw match data.
     * Designed so that {@link androidx.lifecycle.LiveData} and other entities
     * can do object equality checks but still know something has been updated.
     */
    int updateNumber();

    /**
     * The current (possibly partial) state of the raw match data
     */
    ModifiableRawMatchDataUiState modifiableRawMatchData();
}
