package com.example.squirrelscout_scouter.ui.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class MainViewModel extends ViewModel {
    private final MutableLiveData<String> scoutName = new MutableLiveData<>();
    private final MutableLiveData<Short> scoutTeam = new MutableLiveData<>();

    public LiveData<String> getScoutName() {
        return scoutName;
    }

    public LiveData<Short> getScoutTeam() {
        return scoutTeam;
    }

    public void saveScout(String scoutName, short scoutTeam) {
        this.scoutName.setValue(scoutName);
        this.scoutTeam.setValue(scoutTeam);
    }
}
