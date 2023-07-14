package com.example.squirrelscout_scouter;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.example.squirrelscout_scouter.match_scouting_pages.StartScoutingActivity;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    Button startScoutingButton;
    Button pitScouting;
    Button history;

    Button settings;

    EditText scouterName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        startScoutingButton = findViewById(R.id.START_SCOUTING);
        startScoutingButton.setOnClickListener(this);

        pitScouting = findViewById(R.id.PIT_SCOUTING);
        pitScouting.setOnClickListener(this);

        history = findViewById(R.id.HISTORY);
        history.setOnClickListener(this);

        settings = findViewById(R.id.SETTINGS);
        settings.setOnClickListener(this);


        scouterName = findViewById(R.id.SCOUTER_NAME);

    }



    @Override
    public void onClick(View view) {
        int clickedID = view.getId();

        if (clickedID == R.id.START_SCOUTING) {
            startScoutingLogic();
        } else if(clickedID == R.id.HISTORY){
            startHistorylogic();
        } else if(clickedID == R.id.PIT_SCOUTING){
            startPitScoutingLogic();
        } else if(clickedID == R.id.SETTINGS) {
            startSettingsLogic();
        }

    }

    private void startSettingsLogic() {
    }

    private void startPitScoutingLogic() {
        
    }

    private void startHistorylogic() {
        
    }

    public void startScoutingLogic(){
        if(scouterName.getText().toString().trim().equals("") ){
           Log.d("d", "name is blank");
        } else {
            startActivity(new Intent(MainActivity.this, StartScoutingActivity.class));
            Log.d("d", "scouter name: " + scouterName.getText());
        }
    }
}