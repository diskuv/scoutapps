package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.os.Debug;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStoreOwner;

import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ui.viewmodels.ModifiableRawMatchDataUiState;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;

import org.w3c.dom.Text;

public class TeleopActivity extends ComponentActivity implements View.OnClickListener {

    //Speaker Scoring
    TextView speakerTitle;
    ImageView fieldMap;
    //AMP Scoring
    TextView ampTitle, ampMissLabel, ampScoreLabel, ampScoreCounter, ampMissCounter;
    Button ampScoreIncrement, ampScoreDecrement, ampMissIncrement, ampMissDecrement;
    //Breakdown
    AutoCompleteTextView dropdown, dropdown2;
    //Pickup Location
    Button groundButton, sourceButton;
    //Defense
    SeekBar defense;
    //Endgame
    Button parkYes, parkNo, trapYes, trapNo;
    boolean parkBool, trapBool;

    //...
    Button nextButton;


//    ScoutInfo scoutInfo;

    private ScoutingSessionViewModel model;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.teleop_scouting);

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        //model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        //...
        ampScoreCounter = (TextView) findViewById(R.id.AmpScoredCounter);
        ampMissCounter = (TextView) findViewById(R.id.AmpMissedCounter);

        //...
        speakerTitle = (TextView) findViewById(R.id.SpeakerTitle);
        speakerTitle.setOnClickListener(this);
        fieldMap = (ImageView) findViewById(R.id.imageView);
        fieldMap.setOnClickListener(this);
        ampTitle = (TextView) findViewById(R.id.AmpTitle);
        ampTitle.setOnClickListener(this);
        ampScoreIncrement = (Button) findViewById(R.id.Amp_Score_Increment);
        ampScoreIncrement.setOnClickListener(this);
        ampScoreDecrement = (Button) findViewById(R.id.Amp_Score_Decrement);
        ampScoreDecrement.setOnClickListener(this);
        ampMissIncrement = (Button) findViewById(R.id.Amp_Missed_Increment);
        ampMissIncrement.setOnClickListener(this);
        ampMissDecrement = (Button) findViewById(R.id.Amp_Missed_Decrement);
        ampMissDecrement.setOnClickListener(this);
        ampMissLabel = (TextView) findViewById(R.id.AmpMissedLabel);
        ampMissLabel.setOnClickListener(this);
        ampScoreLabel = (TextView) findViewById(R.id.AmpScoredLabel);
        ampScoreLabel.setOnClickListener(this);
        groundButton = (Button) findViewById(R.id.Ground_Pickup);
        groundButton.setOnClickListener(this);
        sourceButton = (Button) findViewById(R.id.Source_Pickup);
        sourceButton.setOnClickListener(this);
        defense = (SeekBar) findViewById(R.id.DefenseBar);
        defense.setOnClickListener(this);
        parkYes = (Button) findViewById(R.id.PARK_YES);
        parkYes.setOnClickListener(this);
        parkNo = (Button) findViewById(R.id.PARK_NO);
        parkNo.setOnClickListener(this);
        trapYes = (Button) findViewById(R.id.TRAP_YES);
        trapYes.setOnClickListener(this);
        trapNo = (Button) findViewById(R.id.TRAP_NO);
        trapNo.setOnClickListener(this);

        //Buttons
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);

        //Breakdown dropdown
        dropdown = findViewById(R.id.dropdown);
        String[] items = new String[]{"Tipped", "Mechanical Failure", "Incapacitated"};
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

        //Climb dropdown
        dropdown2 = findViewById(R.id.dropdown2);
        String[] items2 = new String[]{"Success", "Failed", "Did Not Attempt", "Harmony"};
        ArrayAdapter<String> adapter2 = new ArrayAdapter<>(this, R.layout.dropdown_text, items2);
        dropdown2.setAdapter(adapter2);
        dropdown2.setKeyListener(null);
        dropdown2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dropdown2.showDropDown();
            }
        });
        dropdown2.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                nextPageCheck();
            }
        });

        /*
        // TODO: Keyush/Archit: For Saturday. Do the Model -> UI, and remove scoutInfo.
        // bind view model updates to the UI

        //...
        model.getRawMatchDataSession().observe(this, session -> {
            ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

            if(rawMatchData.incapacitatedIsSet()){
                if(rawMatchData.incapacitated()){
                    incapYesLogic();
                } else {
                    incapNoLogic();
                }
            }

            if(rawMatchData.defenseIsSet()){
                if(rawMatchData.defense()){
                    defenseYesLogic();
                } else {
                    defenseNoLogic();
                }
            }

            if(rawMatchData.coneHighTIsSet()){
                coneHigh.setText(String.valueOf(rawMatchData.coneHighT()));
            }

            if(rawMatchData.coneMidTIsSet()){
                coneMid.setText(String.valueOf(rawMatchData.coneMidT()));
            }

            if(rawMatchData.coneLowTIsSet()) {
                coneLow.setText(String.valueOf(rawMatchData.coneLowT()));
            }

            if(rawMatchData.cubeHighTIsSet()){
                cubeHigh.setText(String.valueOf(rawMatchData.cubeHighT()));
            }

            if(rawMatchData.cubeMidTIsSet()){
                cubeMid.setText(String.valueOf(rawMatchData.cubeMidT()));
            }

            if(rawMatchData.cubeLowTIsSet()){
                cubeLow.setText(String.valueOf(rawMatchData.cubeLowT()));
            }

        });

        //start animation
        animationStart();
         */
    }

    public void onClick(View view){
        int clickedId = view.getId();

        if(clickedId == R.id.imageView){
            //speaker scoring pop up
        }
        else if(clickedId == R.id.Amp_Score_Increment){
            counterIncrementLogic(ampScoreCounter);
        }
        else if(clickedId == R.id.Amp_Score_Decrement){
            counterDecrementLogic(ampScoreCounter);
        }
        else if(clickedId == R.id.Amp_Missed_Increment){
            counterIncrementLogic(ampMissCounter);
        }
        else if(clickedId == R.id.Amp_Missed_Decrement){
            counterDecrementLogic(ampMissCounter);
        }
        else if(clickedId == R.id.Source_Pickup){
            pickUpLocationLogic(sourceButton);
        }
        else if(clickedId == R.id.Ground_Pickup){
            pickUpLocationLogic(groundButton);
        }
        else if(clickedId == R.id.PARK_YES){
            parkYesLogic();
        }
        else if(clickedId == R.id.PARK_NO){
            parkNoLogic();;
        }
        else if(clickedId == R.id.TRAP_YES){
            trapYesLogic();
        }
        else if(clickedId == R.id.TRAP_NO){
            trapNoLogic();
        }
        else if(clickedId == R.id.NEXT){
            animateButton((Button) view);
            nextPageLogic();
        }
    }

    //Park endgame logic
    private void parkYesLogic(){
        //if not selected
        if(parkYes.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            parkYes.setTextColor(ContextCompat.getColor(this, R.color.white));
            parkYes.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            parkNo.setTextColor(ContextCompat.getColor(this, R.color.black));
            parkNo.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            parkBool = true;
            nextPageCheck();
        }
    }
    private void parkNoLogic(){
        //if not selected
        if(parkNo.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            parkYes.setTextColor(ContextCompat.getColor(this, R.color.black));
            parkYes.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            parkNo.setTextColor(ContextCompat.getColor(this, R.color.white));
            parkNo.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            parkBool = false;
            nextPageCheck();
        }
    }

    //trap logic
    private void trapYesLogic(){
        //if not selected
        if(trapYes.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            trapYes.setTextColor(ContextCompat.getColor(this, R.color.white));
            trapYes.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            trapNo.setTextColor(ContextCompat.getColor(this, R.color.black));
            trapNo.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            trapBool = true;
            nextPageCheck();
        }
    }
    private void trapNoLogic(){
        //if not selected
        if(trapNo.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            trapYes.setTextColor(ContextCompat.getColor(this, R.color.black));
            trapYes.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            trapNo.setTextColor(ContextCompat.getColor(this, R.color.white));
            trapNo.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            trapBool = false;
            nextPageCheck();
        }
    }

    //next page logic
    private void nextPageCheck(){
        if(parkYes.getTextColors() != ContextCompat.getColorStateList(this, R.color.green) && !(dropdown.getText().toString().isEmpty()) && !(dropdown2.getText().toString().isEmpty()) && (trapYes.getTextColors() != ContextCompat.getColorStateList(this, R.color.green))){
            nextButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            nextButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
            nextButton.setText("NEXT PAGE");
            Toast.makeText(TeleopActivity.this, dropdown.getText().toString(), Toast.LENGTH_SHORT).show();
        }
    }
    private void nextPageLogic(){
        if(nextButton.getText().toString().equals("NEXT PAGE")){
            Toast.makeText(TeleopActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
            //saveScoutInfo();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(TeleopActivity.this, NotesActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
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

    //pick location logic
    private void pickUpLocationLogic(Button button){
        if(button.getBackgroundTintList() == ContextCompat.getColorStateList(this, R.color.green)){
            button.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.white));
        }
        else {
            button.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));

        }
    }

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(250).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(250);
        }).start();
    }

    /*
    private void animationStart(){
        //animations
        titleCard.setTranslationY(-500);
        titleCard.setAlpha(0f);
        firstCard.setTranslationY(250);
        firstCard.setAlpha(0f);
        secondCard.setTranslationY(250);
        secondCard.setAlpha(0f);
        title.setAlpha(0f);
        title.setTranslationX(-100);
        info.setAlpha(0f);
        info.setTranslationX(-100);
        cone1.setTranslationX(50);
        cone1.setAlpha(0);
        cone2.setTranslationX(50);
        cone2.setAlpha(0);
        cone3.setTranslationX(50);
        cone3.setAlpha(0);
        cube1.setTranslationX(-50);
        cube1.setAlpha(0);
        cube2.setTranslationX(-50);
        cube2.setAlpha(0);
        cube3.setTranslationX(-50);
        cube3.setAlpha(0);
        defenseLayout.setAlpha(0f);
        defenseLayout.setTranslationY(50);
        incapLayout.setAlpha(0f);
        incapLayout.setTranslationY(50);
        climbLayout.setAlpha(0f);
        climbLayout.setTranslationY(50);
        menuLayout.setAlpha(0f);
        menuLayout.setTranslationY(50);
        nextButton.setAlpha(0f);
        nextButton.setTranslationY(50);
        firstCard.animate().alpha(1f).translationYBy(-250).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            secondCard.animate().alpha(1f).translationYBy(-250).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                titleCard.animate().alpha(1f).translationYBy(500).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                    title.animate().alpha(1f).translationXBy(100).setDuration(300);
                    info.animate().alpha(1f).translationXBy(100).setDuration(300);
                    cone1.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cone2.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cone3.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cube1.animate().alpha(1f).translationXBy(50).setDuration(750);
                    cube2.animate().alpha(1f).translationXBy(50).setDuration(750);
                    cube3.animate().alpha(1f).translationXBy(50).setDuration(750);
                    incapLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    defenseLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    climbLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    menuLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    nextButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
                }).start();
            }).start();
        }).start();

    }

    public void saveScoutInfo(){
        // TODO: Keyush/Archit: For Saturday. Do the UI -> Model as a model.captureTeleop()

        model.captureTeleData(
                dropdown.getText().toString(),
                Integer.parseInt(coneHigh.getText().toString()),
                Integer.parseInt(coneMid.getText().toString()),
                Integer.parseInt(coneLow.getText().toString()),
                Integer.parseInt(cubeHigh.getText().toString()),
                Integer.parseInt(cubeMid.getText().toString()),
                Integer.parseInt(cubeLow.getText().toString())
        );

        model.captureIncapAndDefense(incapBool, defenseBool);
    }
     */
}
