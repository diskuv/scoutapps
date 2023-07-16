package com.example.squirrelscout_scouter;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.example.squirrelscout_scouter.match_scouting_pages.StartScoutingActivity;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    Button startScoutingButton;
    Button pitScouting;
    Button history;

    Button settings;

    EditText scouterNameI;
    EditText teamNameI;

    //variables
    String ScoutName;
    String TeamNum;

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

            scouterNameI = (EditText) findViewById(R.id.Name_Input);
            teamNameI = (EditText) findViewById(R.id.TeamNum_Input);

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
        }

    }

    private void startSettingsLogic() {
    }

    private void startPitScoutingLogic() {

    }

    private void startHistorylogic() {

    }

    public void startScoutingLogic(){
        ScoutName = scouterNameI.getText().toString();
        TeamNum = teamNameI.getText().toString();
        if(ScoutName.equals("") || TeamNum.equals("")){
           Log.d("d", "name is blank");
           Toast.makeText(MainActivity.this, "Missing field", Toast.LENGTH_SHORT).show();
        } else {
            startActivity(new Intent(MainActivity.this, StartScoutingActivity.class));
            Log.d("d", "scouter name: " + ScoutName);
            Toast.makeText(MainActivity.this, ScoutName, Toast.LENGTH_SHORT).show();
            Toast.makeText(MainActivity.this, TeamNum, Toast.LENGTH_SHORT).show();
        }
    }
}