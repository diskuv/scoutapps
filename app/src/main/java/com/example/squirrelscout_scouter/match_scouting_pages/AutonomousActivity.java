package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ScoutInfo;

public class AutonomousActivity extends Activity implements View.OnClickListener {

    //instances
    Button coneHi, coneHd, coneMi, coneMd, coneLi, coneLd, cubeHi, cubeHd, cubeMi, cubeMd, cubeLi, cubeLd;
    Button yesMobility, noMobility, nextButton;
    ImageButton homeButton, notesButton;
    TextView coneHigh, coneMid, coneLow, cubeHigh, cubeMid, cubeLow, info;
    AutoCompleteTextView dropdown;

    ScoutInfo scoutInfo;

    //variables
    boolean mobilityBool;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
            setContentView(R.layout.autonomous_scouting);

        //Buttons
        yesMobility = (Button) findViewById(R.id.MOBILITY_YES);
        yesMobility.setOnClickListener(this);
        noMobility = (Button) findViewById(R.id.MOBILITY_NO);
        noMobility.setOnClickListener(this);
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);
        homeButton = (ImageButton) findViewById(R.id.menu_item_1);
        homeButton.setOnClickListener(this);
        notesButton = (ImageButton) findViewById(R.id.menu_item_2);
        notesButton.setOnClickListener(this);
        //...
        coneHi = (Button) findViewById(R.id.CONE_HIGH_INCREMENT);
        coneHi.setOnClickListener(this);
        coneHd = (Button) findViewById(R.id.CONE_HIGH_DECREMENT);
        coneHd.setOnClickListener(this);
        coneMi = (Button) findViewById(R.id.CONE_MID_INCREMENT);
        coneMi.setOnClickListener(this);
        coneMd = (Button) findViewById(R.id.CONE_MID_DECREMENT);
        coneMd.setOnClickListener(this);
        coneLi = (Button) findViewById(R.id.CONE_LOW_INCREMENT);
        coneLi.setOnClickListener(this);
        coneLd = (Button) findViewById(R.id.CONE_LOW_DECREMENT);
        coneLd.setOnClickListener(this);
        cubeHi = (Button) findViewById(R.id.CUBE_HIGH_INCREMENT);
        cubeHi.setOnClickListener(this);
        cubeHd = (Button) findViewById(R.id.CUBE_HIGH_DECREMENT);
        cubeHd.setOnClickListener(this);
        cubeMi = (Button) findViewById(R.id.CUBE_MID_INCREMENT);
        cubeMi.setOnClickListener(this);
        cubeMd = (Button) findViewById(R.id.CUBE_MID_DECREMENT);
        cubeMd.setOnClickListener(this);
        cubeLi = (Button) findViewById(R.id.CUBE_LOW_INCREMENT);
        cubeLi.setOnClickListener(this);
        cubeLd = (Button) findViewById(R.id.CUBE_LOW_DECREMENT);
        cubeLd.setOnClickListener(this);
        //...
        info = (TextView) findViewById(R.id.textView3);

        //counters
        coneHigh = (TextView) findViewById(R.id.ConeHighCounter);
        coneMid = (TextView) findViewById(R.id.ConeMidCounter) ;
        coneLow = (TextView) findViewById(R.id.ConeLowCounter);
        cubeHigh = (TextView) findViewById(R.id.CubeHighCounter) ;
        cubeMid = (TextView) findViewById(R.id.CubeMidCounter);
        cubeLow = (TextView) findViewById(R.id.CubeLowCounter) ;

        //dropdown
        dropdown = findViewById(R.id.dropdown);
        String[] items = new String[]{"Docked", "Engaged", "No Attempt"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
        dropdown.setKeyListener(null);
        dropdown.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dropdown.showDropDown();
            }
        });
        dropdown.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                nextPageCheck();
            }
        });

        //load info if created
        scoutInfo = ScoutInfo.getInstance();
        loadScoutInfo();
    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.menu_item_1){
            startActivity(new Intent(AutonomousActivity.this, MainActivity.class));
        }
        else if(clickedId == R.id.menu_item_2){
            startActivity(new Intent(AutonomousActivity.this, NotesActivity.class));
        }
        else if(clickedId == R.id.MOBILITY_YES){
            mobilityYesLogic();
        }
        else if(clickedId == R.id.MOBILITY_NO){
            mobilityNoLogic();
        }
        else if(clickedId == R.id.NEXT){
            animateButton((Button) view);
            nextPageLogic();
        }
        else if(clickedId == R.id.CONE_HIGH_INCREMENT){
            counterIncrementLogic(coneHigh);
        }
        else if(clickedId == R.id.CONE_HIGH_DECREMENT){
            counterDecrementLogic(coneHigh);
        }
        else if(clickedId == R.id.CONE_MID_INCREMENT){
            counterIncrementLogic(coneMid);
        }
        else if(clickedId == R.id.CONE_MID_DECREMENT){
            counterDecrementLogic(coneMid);
        }
        else if(clickedId == R.id.CONE_LOW_INCREMENT){
            counterIncrementLogic(coneLow);
        }
        else if(clickedId == R.id.CONE_LOW_DECREMENT){
            counterDecrementLogic(coneLow);
        }
        else if(clickedId == R.id.CUBE_HIGH_INCREMENT){
            counterIncrementLogic(cubeHigh);
        }
        else if(clickedId == R.id.CUBE_HIGH_DECREMENT){
            counterDecrementLogic(cubeHigh);
        }
        else if(clickedId == R.id.CUBE_MID_INCREMENT){
            counterIncrementLogic(cubeMid);
        }
        else if(clickedId == R.id.CUBE_MID_DECREMENT){
            counterDecrementLogic(cubeMid);
        }
        else if(clickedId == R.id.CUBE_LOW_INCREMENT){
            counterIncrementLogic(cubeLow);
        }
        else if(clickedId == R.id.CUBE_LOW_DECREMENT){
            counterDecrementLogic(cubeLow);
        }

    }

    //mobility logic
    private void mobilityYesLogic(){
        //if not selected
        if(yesMobility.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesMobility.setTextColor(ContextCompat.getColor(this, R.color.white));
            yesMobility.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            noMobility.setTextColor(ContextCompat.getColor(this, R.color.black));
            noMobility.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            mobilityBool = true;
            nextPageCheck();
        }
    }
    private void mobilityNoLogic(){
        //if not selected
        if(noMobility.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesMobility.setTextColor(ContextCompat.getColor(this, R.color.black));
            yesMobility.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            noMobility.setTextColor(ContextCompat.getColor(this, R.color.white));
            noMobility.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            mobilityBool = false;
            nextPageCheck();
        }
    }

    //next page logic
    private void nextPageCheck(){
        if(yesMobility.getTextColors() != ContextCompat.getColorStateList(this, R.color.green) && !(dropdown.getText().toString().isEmpty())){
            nextButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            nextButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
            nextButton.setText("NEXT PAGE");
            Toast.makeText(AutonomousActivity.this, dropdown.getText().toString(), Toast.LENGTH_SHORT).show();
        }
    }
    private void nextPageLogic(){
        if(nextButton.getText().toString().equals("NEXT PAGE")){
            Toast.makeText(AutonomousActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(AutonomousActivity.this, TeleopActivity.class));
        }
    }

    //Counter increment and decrement logic
    private void counterIncrementLogic(TextView counter) {
        String matchString = counter.getText().toString();
        try {
            int num = Integer.parseInt(matchString);
            counter.setText(String.valueOf(num + 1));
        } catch (NumberFormatException e) {
            // Handle the case where the input string is not a valid integer
            // Display an error message or perform appropriate error handling
            e.printStackTrace();
        }
    }
    private void counterDecrementLogic(TextView counter) {
        String matchString = counter.getText().toString();
        try {
            int num = Integer.parseInt(matchString);
            if(num - 1 < 0){
                counter.setText("0");
            }else{
                counter.setText(String.valueOf(num - 1));
            }
        } catch (NumberFormatException e) {
            // Handle the case where the input string is not a valid integer
            // Display an error message or perform appropriate error handling
            e.printStackTrace();
        }
    }

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(250).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(250);
        }).start();
    }

    //loading the scout info
    public void loadScoutInfo(){
        //gets the match and team number that the scout should be scouting
        info.setText("Match #" + scoutInfo.getScoutMatch() + "\n" + scoutInfo.getRobotScouting());
    }
}
