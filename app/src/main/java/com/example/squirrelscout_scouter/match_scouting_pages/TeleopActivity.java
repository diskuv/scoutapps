package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.media.Image;
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

public class TeleopActivity extends Activity implements View.OnClickListener {

    //instances
    Button coneHi, coneHd, coneMi, coneMd, coneLi, coneLd, cubeHi, cubeHd, cubeMi, cubeMd, cubeLi, cubeLd;
    Button yesDefense, noDefense, yesIncap, noIncap,nextButton;
    ImageButton backPage, notesPage;
    TextView coneHigh, coneMid, coneLow, cubeHigh, cubeMid, cubeLow;
    AutoCompleteTextView dropdown;

    //variables
    boolean defenseBool, incapBool;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.teleop_scouting);

        //Buttons
        yesDefense = (Button) findViewById(R.id.DEFENSE_YES);
        yesDefense.setOnClickListener(this);
        noDefense = (Button) findViewById(R.id.DEFENSE_NO);
        noDefense.setOnClickListener(this);
        yesIncap = (Button) findViewById(R.id.INCAP_YES);
        yesIncap.setOnClickListener(this);
        noIncap = (Button) findViewById(R.id.INCAP_NO);
        noIncap.setOnClickListener(this);
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);
        backPage = (ImageButton) findViewById(R.id.menu_item_1);
        backPage.setOnClickListener(this);
        notesPage = (ImageButton) findViewById(R.id.menu_item_2);
        notesPage.setOnClickListener(this);
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
                //...
            }
        });
        dropdown.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                nextPageCheck();
            }
        });

    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.DEFENSE_YES){
            defenseYesLogic();
        }
        else if(clickedId == R.id.DEFENSE_NO){
            defenseNoLogic();
        }
        else if(clickedId == R.id.INCAP_YES){
            incapYesLogic();
        }
        else if(clickedId == R.id.INCAP_NO){
            incapNoLogic();
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

    //defense logic
    private void defenseYesLogic(){
        //if not selected
        if(yesDefense.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesDefense.setTextColor(ContextCompat.getColor(this, R.color.white));
            yesDefense.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            noDefense.setTextColor(ContextCompat.getColor(this, R.color.black));
            noDefense.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            defenseBool = true;
            nextPageCheck();
        }
    }
    private void defenseNoLogic(){
        //if not selected
        if(noDefense.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesDefense.setTextColor(ContextCompat.getColor(this, R.color.black));
            yesDefense.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            noDefense.setTextColor(ContextCompat.getColor(this, R.color.white));
            noDefense.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            defenseBool = false;
            nextPageCheck();
        }
    }

    //incap logic
    private void incapYesLogic(){
        //if not selected
        if(yesIncap.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesIncap.setTextColor(ContextCompat.getColor(this, R.color.white));
            yesIncap.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            noIncap.setTextColor(ContextCompat.getColor(this, R.color.black));
            noIncap.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            defenseBool = true;
            nextPageCheck();
        }
    }
    private void incapNoLogic(){
        //if not selected
        if(noIncap.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesIncap.setTextColor(ContextCompat.getColor(this, R.color.black));
            yesIncap.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            noIncap.setTextColor(ContextCompat.getColor(this, R.color.white));
            noIncap.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            defenseBool = false;
            nextPageCheck();
        }
    }

    //next page logic
    private void nextPageCheck(){
        if(yesDefense.getTextColors() != ContextCompat.getColorStateList(this, R.color.green) && !(dropdown.getText().toString().isEmpty()) && yesIncap.getTextColors() != ContextCompat.getColorStateList(this, R.color.green)){
            nextButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            nextButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
            nextButton.setText("NEXT PAGE");
            Toast.makeText(TeleopActivity.this, dropdown.getText().toString(), Toast.LENGTH_SHORT).show();
        }
    }
    private void nextPageLogic(){
        if(nextButton.getText().toString().equals("NEXT PAGE")){
            Toast.makeText(TeleopActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(TeleopActivity.this, NotesActivity.class));
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
}
