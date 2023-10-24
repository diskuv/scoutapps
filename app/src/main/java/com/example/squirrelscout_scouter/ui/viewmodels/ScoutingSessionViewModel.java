package com.example.squirrelscout_scouter.ui.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

/**
 * The information associated with a single Start Scouting session.
 */
public class ScoutingSessionViewModel extends ViewModel {
    /**
     * Some unique identifier so we know when a new session has been started
     */
    public static final String INTENT_INITIAL_LONG_SESSION_NUMBER = "Initial:SessionNumber";
    public static final String INTENT_INITIAL_STRING_SCOUT_NAME = "Initial:ScoutName";
    public static final String INTENT_INITIAL_SHORT_TEAM_NUMBER = "Initial:TeamNumber";

    /**
     * Be careful with Mutable on top of a Modifiable! Any modifications need to
     * also mutate the MutableLiveData or else notifications will not be sent.
     *
     * So make sure you do a .postValue() or a .setValue() after _ANY_
     * modifications to [modifiableRawMatchData].
     */
    private final MutableLiveData<ImmutableRawMatchDataSessionUiState> rawMatchDataSessionUiState =
            new MutableLiveData<>(ImmutableRawMatchDataSessionUiState.builder()
                    .sessionNumber(0L)
                    .modifiableRawMatchData(ModifiableRawMatchDataUiState.create())
                    .build());

    public LiveData<ImmutableRawMatchDataSessionUiState> getRawMatchDataSession() {
        return rawMatchDataSessionUiState;
    }

    public void startNewSessionIfNecessary(long sessionNumber, String scoutName, short teamNumber) {
        ImmutableRawMatchDataSessionUiState oldState = rawMatchDataSessionUiState.getValue();
        if (oldState == null || oldState.sessionNumber() != sessionNumber) {
            // new session! everything should be cleared except the scout name and team number
            ModifiableRawMatchDataUiState state = ModifiableRawMatchDataUiState.create();
            state.setScoutName(scoutName);
            state.setScoutTeam(teamNumber);
            rawMatchDataSessionUiState.postValue(
                    ImmutableRawMatchDataSessionUiState.builder()
                            .sessionNumber(sessionNumber)
                            .modifiableRawMatchData(state)
                            .build()
            );
        }
    }
}
