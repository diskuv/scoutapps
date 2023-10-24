package com.example.squirrelscout_scouter.ui.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.caverock.androidsvg.SVG;
import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.capnp.Schema;
import com.example.squirrelscout.data.models.ComDataModel;

import org.capnproto.MessageBuilder;

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
     * <p>
     * So make sure you do a .postValue() or a .setValue() after _ANY_
     * modifications to [modifiableRawMatchData], and you also update some other
     * field.
     * <p>
     * In most cases just use updateAndSetSession().
     */
    private final MutableLiveData<ImmutableRawMatchDataSessionUiState> rawMatchDataSessionUiState =
            new MutableLiveData<>(ImmutableRawMatchDataSessionUiState.builder()
                    .sessionNumber(0L)
                    .updateNumber(0)
                    .modifiableRawMatchData(ModifiableRawMatchDataUiState.create())
                    .build());

    public LiveData<ImmutableRawMatchDataSessionUiState> getRawMatchDataSession() {
        return rawMatchDataSessionUiState;
    }

    private void updateAndSetSession(ImmutableRawMatchDataSessionUiState session) {
        ImmutableRawMatchDataSessionUiState updatedSession = session.withUpdateNumber(session.updateNumber() + 1);
        rawMatchDataSessionUiState.setValue(updatedSession);
    }

    public String printSession() {
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        return session == null ? "no session" : session.toString();
    }

    public void startNewSessionIfNecessary(long sessionNumber, String scoutName, short teamNumber) {
        ImmutableRawMatchDataSessionUiState oldState = rawMatchDataSessionUiState.getValue();
        if (oldState == null || oldState.sessionNumber() != sessionNumber) {
            // new session! everything should be cleared except the scout name and team number
            ModifiableRawMatchDataUiState state = ModifiableRawMatchDataUiState.create();
            state.setScoutName(scoutName);
            state.setScoutTeam(teamNumber);
            rawMatchDataSessionUiState.setValue(
                    ImmutableRawMatchDataSessionUiState.builder()
                            .sessionNumber(sessionNumber)
                            .updateNumber(0)
                            .modifiableRawMatchData(state)
                            .build()
            );
        }
    }

    //need to implement
    //gets the robot based on the match number and position
    public void findRobot() {
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert session != null;
        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        //placement for now
        rawMatchData.setRobotScouting(1234);

        updateAndSetSession(session);
    }

    public void captureMatchRobot(int scoutMatch, String robotPosition) {
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert session != null;
        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setMatchScouting(scoutMatch);
        rawMatchData.setPositionScouting(robotPosition);

        updateAndSetSession(session);
    }

    public SVG generateQrCode(ComDataModel data) {
        MessageBuilder rawMatchData = Com.newMessageBuilder();
        Schema.RawMatchData.Builder builder = rawMatchData.initRoot(Schema.RawMatchData.factory);
        builder.setNotes("hello squirrel scouters!");
        return data.getScoutQR().qrCodeOfRawMatchData(rawMatchData);
    }
}
