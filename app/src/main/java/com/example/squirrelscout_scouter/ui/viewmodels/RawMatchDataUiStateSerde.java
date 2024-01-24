package com.example.squirrelscout_scouter.ui.viewmodels;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.capnp.Schema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

/**
 * Serialization/deserialization for {@link RawMatchDataUiState}.
 */
// Package-protected since only the ViewModels ... the entities responsible
// for converting the UiState into data layer model objects (capnp) ... should use this.
class RawMatchDataUiStateSerde {
    /*
        DEVELOPERS:

        Yes this is tedious writing this. But _always_ separate your data layer model objects
        from your UI state objects. That way your Android UI can change without forcing
        everything else (ex. iOS UI, manager app) to change.

        These are "strong recommendations" from
        https://developer.android.com/topic/architecture/recommendations#layered-architecture
     */

    public Schema.Climb stringToClimb(String climbString) {
        switch (climbString){
            case "Docked":
                return Schema.Climb.DOCKED;

            case "Engaged":
                return Schema.Climb.ENGAGED;

            case "No Attempt":
                return Schema.Climb.NONE;

            default:
                return Schema.Climb.NONE;
        }
    }
    public MessageBuilder toMessage(RawMatchDataUiState v) {
        MessageBuilder message = Com.newMessageBuilder();
        Schema.RawMatchData.Builder rawMatchData = message.initRoot(Schema.RawMatchData.factory);

        // TODO: Keyush/Archit: For Saturday. Finish conversion to capnp.

        //scouter person
        rawMatchData.setScouterName(v.scoutName());

        //match/robot info
        rawMatchData.setTeamNumber((short) v.robotScouting());
        rawMatchData.setTeamName("NO_NAME");
        rawMatchData.setMatchNumber( (short) v.matchScouting());

        //general non-game specific
        rawMatchData.setIncap(v.incapacitated());
        rawMatchData.setPlayingDefense(v.defense());
        rawMatchData.setNotes(v.notes());

        //auto
        rawMatchData.setAutoClimb(stringToClimb(v.autoClimb()));
        rawMatchData.setAutoMobility(v.mobility());

        rawMatchData.setAutoConeHigh((short) v.coneHighA());
        rawMatchData.setAutoConeMid((short) v.coneMidA());
        rawMatchData.setAutoConeLow((short) v.coneLowA());

        rawMatchData.setAutoCubeHigh((short) v.cubeHighA());
        rawMatchData.setAutoCubeMid((short) v.cubeMidA());
        rawMatchData.setAutoCubeLow((short) v.cubeLowA());

        //tele
        rawMatchData.setTeleClimb(stringToClimb(v.teleClimb()));

        rawMatchData.setTeleConeHigh((short) v.coneHighT());
        rawMatchData.setTeleConeMid((short) v.coneMidT());
        rawMatchData.setTeleConeLow((short) v.coneLowT());

        rawMatchData.setTeleCubeHigh((short) v.cubeHighT());
        rawMatchData.setTeleCubeMid((short) v.cubeMidT());
        rawMatchData.setTeleCubeLow((short) v.cubeLowT());



        return message;
    }

    public ImmutableRawMatchDataUiState fromMessageReader(MessageReader reader) {
        Schema.RawMatchData.Reader root = reader.getRoot(Schema.RawMatchData.factory);
        ImmutableRawMatchDataUiState.Builder builder = ImmutableRawMatchDataUiState.builder();

        // etc.
        builder.coneHighA(root.getAutoConeHigh());

        return builder.build();
    }
}
