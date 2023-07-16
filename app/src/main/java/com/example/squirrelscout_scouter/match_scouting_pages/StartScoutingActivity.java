package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.PopupMenu;

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
        robotPositionButton = findViewById(R.id.START_SCOUTING_ROBOT_POSITION_BUTTON);
        settingButton = findViewById(R.id.SETTINGS);


        //giving actions to the buttons
        robotPositionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPopUp();
            }
        });

        settingButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(StartScoutingActivity.this, MainActivity.class));
                Log.d("e", "Going back to home");
            }
        });
    }

    private void showPopUp(){
        PopupMenu popup = new PopupMenu(StartScoutingActivity.this, findViewById(R.id.START_SCOUTING_ROBOT_POSITION_BUTTON));
        popup.inflate(R.menu.robot_position_selector);
        popup.show();

        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem menuItem) {
                robotPositionButton.setText(menuItem.getTitle());

                return true;
            }
        });
    }


}
