package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.PopupMenu;
import android.widget.Spinner;

import androidx.annotation.Nullable;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;

public class StartScoutingActivity extends Activity {

    Button robotPositionButton;
    Button settingButton;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_scouting);

        //initializing all buttons to a component
//        robotPositionButton = findViewById(R.id.START_SCOUTING_ROBOT_POSITION_BUTTON);
//        settingButton = findViewById(R.id.SETTINGS);

        //dropdown
        AutoCompleteTextView dropdown = findViewById(R.id.dropdown);
        String[] items = new String[]{"Red 1", "Red 2", "Red 3", "Blue 1", "Blue 2", "Blue 3"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
        dropdown.setKeyListener(null);
        dropdown.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dropdown.showDropDown();
            }
        });



        //giving actions to the buttons
    }


}
