package com.example.squirrelscout_scouter.ui.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

/**
 * The information associated with a single Start Scouting session.
 */
public class ScoutingSessionViewModel extends ViewModel {
    private final MutableLiveData<ImmutableRawMatchDataUiState> rawMatchDataUiState =
            new MutableLiveData<>(ImmutableRawMatchDataUiState.builder().build());

    public LiveData<ImmutableRawMatchDataUiState> getRawMatchDataUiState() {
        return rawMatchDataUiState;
    }
}
