package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.PopupMenu;

import androidx.annotation.Nullable;

import com.example.squirrelscout_scouter.R;

public class StartScoutingActivity extends Activity {

    Button robotPositionButton;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_scouting);

        robotPositionButton = findViewById(R.id.START_SCOUTING_ROBOT_POSITION_BUTTON);

        robotPositionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPopUp();
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
