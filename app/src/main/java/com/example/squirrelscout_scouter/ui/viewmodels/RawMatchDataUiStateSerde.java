package com.example.squirrelscout_scouter.ui.viewmodels;

import com.example.squirrelscout.data.capnp.Schema;

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
    public Schema.RawMatchData.Reader toReader(RawMatchDataUiState v) {
        org.capnproto.MessageBuilder message = new org.capnproto.MessageBuilder();
        Schema.RawMatchData.Builder rawMatchData = message.initRoot(Schema.RawMatchData.factory);

        // etc.
        rawMatchData.setAutoConeHigh((short) v.coneHighA());

        return rawMatchData.asReader();
    }

    public ImmutableRawMatchDataUiState fromMessageReader(MessageReader reader) {
        Schema.RawMatchData.Reader root = reader.getRoot(Schema.RawMatchData.factory);
        ImmutableRawMatchDataUiState.Builder builder = ImmutableRawMatchDataUiState.builder();

        // etc.
        builder.coneHighA(root.getAutoConeHigh());

        return builder.build();
    }
}
