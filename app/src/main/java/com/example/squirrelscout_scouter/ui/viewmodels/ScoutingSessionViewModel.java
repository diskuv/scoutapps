package com.example.squirrelscout_scouter.ui.viewmodels;

import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;
import androidx.lifecycle.ViewModel;

import com.caverock.androidsvg.SVG;
import com.example.squirrelscout.data.models.ComDataModel;

import org.capnproto.MessageBuilder;

import java.util.Objects;

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

    private final MutableLiveData<ImmutableRawMatchDataUiState> qrRequests = new MutableLiveData<>();

    private final LiveData<ImmutableRawMatchDataUiState> completedRawMatchData =
            Transformations.distinctUntilChanged(
                    Transformations.map(rawMatchDataSessionUiState, this::fromSessionToCompleted));

    /**
     * The "session" raw match data will be emitted whenever there is a change
     * to the session fields.
     */
    public LiveData<ImmutableRawMatchDataSessionUiState> getRawMatchDataSession() {
        return rawMatchDataSessionUiState;
    }

    /**
     * The "completed" raw match data will be emitted when the session is complete.
     */
    public LiveData<ImmutableRawMatchDataUiState> getCompletedRawMatchData() {
        return completedRawMatchData;
    }

    /**
     * The "QR requests" will be emitted whenever there is a new request for a QR code.
     */
    public LiveData<ImmutableRawMatchDataUiState> getQrRequests() {
        return qrRequests;
    }

    private void updateAndSetSession(ImmutableRawMatchDataSessionUiState session) {
        ImmutableRawMatchDataSessionUiState updatedSession = session.withUpdateNumber(session.updateNumber() + 1);
        rawMatchDataSessionUiState.setValue(updatedSession);
    }

    /**
     * Return a non-null RawMatchData if and only if the session fields are complete.
     *
     * @param session the partially completed session
     * @return the completed RawMatchData, or null if incomplete
     */
    private ImmutableRawMatchDataUiState fromSessionToCompleted(ImmutableRawMatchDataSessionUiState session) {
        // TODO: The UI is not complete:
        // - We pretend as if the UI completed all the fields.
        // - But we do _not_ touch the session ... we instead operate on a clone of the
        //   session and fill in the clone's fields. That way the real UI can keep track
        //   of which fields have been set and which haven't.
        ModifiableRawMatchDataUiState clone = ModifiableRawMatchDataUiState.create().from(
                session.modifiableRawMatchData()
        );

        // This check should not be needed when the UI is complete!
        try {
            clone.toImmutable();
        } catch (IllegalStateException e) {
            Log.e("ScoutingSession", "The UI has not been completed! For now we'll try to patch the UI fields. The following error message should tell you which fields still need to be set: " + e.getMessage());
            // TODO: Keyush/Archit: For Saturday. All of these should be marked DONE once they are set from the *Activity pages
            // DONE: if (!clone.scoutTeamIsSet()) clone.setScoutTeam(-1);
            // DONE: if (!clone.scoutNameIsSet()) clone.setScoutName("UI needs setScoutName");
//            if (!clone.positionScoutingIsSet())
//                clone.setPositionScouting("UI needs setPositionScouting");
//            if (!clone.matchScoutingIsSet()) clone.setMatchScouting(-1);
//            if (!clone.autoClimbIsSet()) clone.setAutoClimb("UI needs setAutoClimb");
//            if (!clone.incapacitatedIsSet()) clone.setIncapacitated(false);
//            if (!clone.defenseIsSet()) clone.setDefense(false);
//            if (!clone.mobilityIsSet()) clone.setMobility(false);
            if (!clone.notesIsSet()) clone.setNotes("UI needs setNotes");
//            if (!clone.teleClimbIsSet()) clone.setTeleClimb("UI needs setTeleClimb");
//            if (!clone.coneHighAIsSet()) clone.setConeHighA(-1);
//            if (!clone.coneHighTIsSet()) clone.setConeHighT(-1);
//            if (!clone.coneMidAIsSet()) clone.setConeMidA(-1);
//            if (!clone.coneMidTIsSet()) clone.setConeMidT(-1);
//            if (!clone.coneLowAIsSet()) clone.setConeLowA(-1);
//            if (!clone.coneLowTIsSet()) clone.setConeLowT(-1);
//            if (!clone.cubeHighAIsSet()) clone.setCubeHighA(-1);
//            if (!clone.cubeHighTIsSet()) clone.setCubeHighT(-1);
//            if (!clone.cubeMidAIsSet()) clone.setCubeMidA(-1);
//            if (!clone.cubeMidTIsSet()) clone.setCubeMidT(-1);
//            if (!clone.cubeLowAIsSet()) clone.setCubeLowA(-1);
//            if (!clone.cubeLowTIsSet()) clone.setCubeLowT(-1);
        }

        return clone.toImmutable();
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

    //TODO: Add this functionality in later. Remove the manual entering of robot number
//    public void findRobot() {
//        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
//        assert session != null;
//        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();
//
//        //placement for now
//        rawMatchData.setRobotScouting(1234);
//
//        updateAndSetSession(session);
//    }

    public void captureScoutingRobotNumber(int num){
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert session != null;
        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setRobotScouting(num);
    }

    public void captureMatchRobot(int scoutMatch, String robotPosition) {
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert session != null;
        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setMatchScouting(scoutMatch);
        rawMatchData.setPositionScouting(robotPosition);

        updateAndSetSession(session);
    }

    public void captureAutoData(boolean leave, String position, boolean wing1, boolean wing2, boolean wing3, boolean center1, boolean center2, boolean center3, boolean center4, boolean center5){
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert  session != null;

        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setMobility(mobility);
        rawMatchData.setAutoClimb(climb);

        rawMatchData.setConeHighA(coneHigh);
        rawMatchData.setConeMidA(coneMid);
        rawMatchData.setConeLowA(coneLow);

        rawMatchData.setCubeHighA(cubeHigh);
        rawMatchData.setCubeMidA(cubeMid);
        rawMatchData.setCubeLowA(cubeLow);

        //does this need to be called? would this overwrite/lose the previous captureMatchRobot method's session data?
        updateAndSetSession(session);
    }

    public void captureTeleData(String climb, int coneHigh, int coneMid, int coneLow, int cubeHigh, int cubeMid, int cubeLow){
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert  session != null;

        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setTeleClimb(climb);
        rawMatchData.setConeHighT(coneHigh);
        rawMatchData.setConeMidT(coneMid);
        rawMatchData.setConeLowT(coneLow);

        rawMatchData.setCubeHighT(cubeHigh);
        rawMatchData.setCubeMidT(cubeMid);
        rawMatchData.setCubeLowT(cubeLow);

        updateAndSetSession(session);
    }

    public void captureIncapAndDefense(boolean incap, boolean playingDefense){
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert  session != null;

        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setIncapacitated(incap);
        rawMatchData.setDefense(playingDefense);

        updateAndSetSession(session);
    }

    public void captureNotes(String notes){
        ImmutableRawMatchDataSessionUiState session = rawMatchDataSessionUiState.getValue();
        assert  session != null;

        ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

        rawMatchData.setNotes(notes);

        updateAndSetSession(session);

    }

    public void requestQrCode() {
        ImmutableRawMatchDataUiState completeRawMatchData = completedRawMatchData.getValue();
        /* Do nothing if the session is not complete. You should set the UI button (etc.) to
           not be visible so you never request a QR code. */
        if (completeRawMatchData == null) return;
        qrRequests.setValue(completeRawMatchData);
    }

    public SVG generateQrCode(ComDataModel data, ImmutableRawMatchDataUiState completeRawMatchData) {
        MessageBuilder completeRawMatchDataMessage = new RawMatchDataUiStateSerde()
                .toMessage(Objects.requireNonNull(completeRawMatchData));
        return data.getScoutQR().qrCodeOfRawMatchData(completeRawMatchDataMessage);
    }
}
