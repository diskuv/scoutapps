package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.CheckBox;
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
import com.example.squirrelscout_scouter.util.ScoutSingleton;

public class AutonomousActivity extends ComponentActivity implements View.OnClickListener {

    //Increment/decrement buttons
    Button speakerScoreIncrement, speakerScoreDecrement, speakerMissIncrement, speakerMissDecrement, ampScoreIncrement, ampScoreDecrement, ampMissInrecement, ampMissDecrement;
    TextView speakerScore, speakerMiss, ampScore, ampMiss;

    //robot position
    Button leftPosition, centerPosition, rightPosition;
    String robotPosition = "";

    //checkboxes
    CheckBox checkBox1, checkBox2, checkBox3, checkBox4, checkBox5, checkBox6, checkBox7, checkBox8, checkBox9, checkBox10, checkBox11;
    boolean wing1 = false;
    boolean wing2 = false;
    boolean wing3 = false;
    boolean center1 = false;
    boolean center2 = false;
    boolean center3 = false;
    boolean center4 = false;
    boolean center5 = false;
    int firstAutoPickup = -1;

    //Leave mobility
    Button yesLeave, noLeave;
    boolean leaveBool;

    //next Button
    Button nextButton;
    TextView info, title;
    View titleCard, firstCard, secondCard, mainCard;
    private ScoutingSessionViewModel model;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
            setContentView(R.layout.autonomous_scouting);

            //...
        ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();
        TextView label = (TextView) findViewById(R.id.textView3);
        label.setText("Match #" + scoutSingleton.getMatchNum() + "\n" + scoutSingleton.getRobotNum());

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        //speaker & amp scoring
        speakerScoreIncrement = (Button) findViewById(R.id.Speaker_Scored_increment);
        speakerScoreIncrement.setOnClickListener(this);
        speakerScoreDecrement = (Button) findViewById(R.id.Speaker_Scored_decrement);
        speakerScoreDecrement.setOnClickListener(this);
        speakerMissIncrement = (Button) findViewById(R.id.Speaker_Missed_Increment);
        speakerMissIncrement.setOnClickListener(this);
        speakerMissDecrement = (Button) findViewById(R.id.Speaker_Missed_Decrement);
        speakerMissDecrement.setOnClickListener(this);
        ampScoreIncrement = (Button) findViewById(R.id.Amp_Score_Increment);
        ampScoreIncrement.setOnClickListener(this);
        ampScoreDecrement = (Button) findViewById(R.id.Amp_Score_Decrement);
        ampScoreDecrement.setOnClickListener(this);
        ampMissInrecement = (Button) findViewById(R.id.Amp_Missed_Increment);
        ampMissInrecement.setOnClickListener(this);
        ampMissDecrement = (Button) findViewById(R.id.Amp_Missed_Decrement);
        ampMissDecrement.setOnClickListener(this);
        speakerScore = (TextView) findViewById(R.id.SpeakerScoredCounter);
        speakerScore.setOnClickListener(this);
        speakerMiss = (TextView) findViewById(R.id.SpeakerMissedCounter);
        speakerMiss.setOnClickListener(this);
        ampScore = (TextView) findViewById(R.id.AmpScoredCounter);
        ampScore.setOnClickListener(this);
        ampMiss = (TextView) findViewById(R.id.AmpMissedCounter);
        ampMiss.setOnClickListener(this);

        //robot Position
        leftPosition = (Button) findViewById(R.id.Start_Left);
        leftPosition.setOnClickListener(this);
        centerPosition = (Button) findViewById(R.id.Start_Center);
        centerPosition.setOnClickListener(this);
        rightPosition = (Button) findViewById(R.id.Start_Right);
        rightPosition.setOnClickListener(this);

        //checkboxes
        checkBox1 = (CheckBox) findViewById(R.id.checkBox);
        checkBox1.setOnClickListener(this);
        checkBox2 = (CheckBox) findViewById(R.id.checkBox2);
        checkBox2.setOnClickListener(this);
        checkBox3 = (CheckBox) findViewById(R.id.checkBox3);
        checkBox3.setOnClickListener(this);
        checkBox4 = (CheckBox) findViewById(R.id.checkBox4);
        checkBox4.setOnClickListener(this);
        checkBox5 = (CheckBox) findViewById(R.id.checkBox5);
        checkBox5.setOnClickListener(this);
        checkBox6 = (CheckBox) findViewById(R.id.checkBox6);
        checkBox6.setOnClickListener(this);
        checkBox7 = (CheckBox) findViewById(R.id.checkBox7);
        checkBox7.setOnClickListener(this);
        checkBox8 = (CheckBox) findViewById(R.id.checkBox8);
        checkBox8.setOnClickListener(this);
        checkBox9 = (CheckBox) findViewById(R.id.checkBox9);
        checkBox9.setOnClickListener(this);
        checkBox10 = (CheckBox) findViewById(R.id.checkBox10);
        checkBox10.setOnClickListener(this);
        checkBox11 = (CheckBox) findViewById(R.id.checkBox11);
        checkBox11.setOnClickListener(this);

        //leave auto points
        yesLeave = (Button) findViewById(R.id.LEAVE_YES);
        yesLeave.setOnClickListener(this);
        noLeave = (Button) findViewById(R.id.LEAVE_NO);
        noLeave.setOnClickListener(this);

        //Buttons
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);
        //...
        info = (TextView) findViewById(R.id.textView3);
        titleCard = (View) findViewById(R.id.view);
        mainCard = (View) findViewById(R.id.view2);
        firstCard = (View) findViewById(R.id.view3);
        secondCard = (View) findViewById(R.id.view4);
        title = (TextView) findViewById(R.id.textView2);

        //start animation
        //animationStart();
    }

    public void onClick(View view){
        int clickedId = view.getId();

        if(clickedId == R.id.Amp_Score_Increment){
            counterIncrementLogic(ampScore);
        }
        else if(clickedId == R.id.Amp_Score_Decrement){
            counterDecrementLogic(ampScore);
        }
        else if(clickedId == R.id.Amp_Missed_Increment){
            counterIncrementLogic(ampMiss);
        }
        else if(clickedId == R.id.Amp_Missed_Decrement){
            counterDecrementLogic(ampMiss);
        }
        else if(clickedId == R.id.Speaker_Scored_increment){
            counterIncrementLogic(speakerScore);
        }
        else if(clickedId == R.id.Speaker_Scored_decrement){
            counterDecrementLogic(speakerScore);
        }
        else if(clickedId == R.id.Speaker_Missed_Increment){
            counterIncrementLogic(speakerMiss);
        }
        else if(clickedId == R.id.Speaker_Missed_Decrement){
            counterDecrementLogic(speakerMiss);
        }
        else if(clickedId == R.id.Start_Left){
            robotLeftLogic();
        }
        else if(clickedId == R.id.Start_Center){
            robotCenterLogic();
        }
        else if(clickedId == R.id.Start_Right){
            robotRightLogic();
        }
        else if(clickedId == R.id.LEAVE_YES){
            yesLeaveLogic();
        }
        else if(clickedId == R.id.LEAVE_NO){
            noLeaveLogic();
        }
        else if(clickedId == R.id.NEXT){
            animateButton((Button) view);
            nextPageLogic();
        }
        else if(view instanceof CheckBox){
            CheckBox checkBox = (CheckBox) view;
            if (checkBox.isChecked() && firstAutoPickup == -1) {
                // Store the ID of the first selected checkbox
                firstAutoPickup = clickedId;
                Log.d("checkbox", "picked" + firstAutoPickup);
            }
            else if(firstAutoPickup == clickedId){
                firstAutoPickup = -1;
                Log.d("checkbox", "picked" + firstAutoPickup);
            }
        }
    }

    //Robot position logic
    private void robotLeftLogic(){
        //if not selected
        if(leftPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Amp Side";
            nextPageCheck();
        }
    }
    private void robotRightLogic(){
        ///if not selected
        if(rightPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Source Side";
            nextPageCheck();
        }
    }
    private void robotCenterLogic(){
        //if not selected
        if(centerPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Center";
            nextPageCheck();
        }
    }

    //Leave mobility logic
    private void yesLeaveLogic(){
        //if not selected
        if(yesLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesLeave.setTextColor(ContextCompat.getColor(this, R.color.white));
            yesLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            noLeave.setTextColor(ContextCompat.getColor(this, R.color.black2));
            noLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            leaveBool = true;
            nextPageCheck();
        }
    }
    private void noLeaveLogic(){
        //if not selected
        if(noLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            noLeave.setTextColor(ContextCompat.getColor(this, R.color.white));
            noLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            yesLeave.setTextColor(ContextCompat.getColor(this, R.color.black2));
            yesLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            leaveBool = false;
            nextPageCheck();
        }
    }

    //next page logic
    private void nextPageCheck(){
        if(yesLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.green) && !(robotPosition.isEmpty())){
            nextButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            nextButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
            nextButton.setText("NEXT PAGE");
        }
    }
    private void nextPageLogic(){
        if(nextButton.getText().toString().equals("NEXT PAGE")){
            Toast.makeText(AutonomousActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(AutonomousActivity.this, TeleopActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            saveScoutInfo();
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
        mobilityLayout.setAlpha(0f);
        mobilityLayout.setTranslationY(50);
        climbLayout.setAlpha(0f);
        climbLayout.setTranslationY(50);
        menuLayout.setAlpha(0f);
        menuLayout.setTranslationY(50);
        nextButton.setAlpha(0f);
        nextButton.setTranslationY(50);
//        title.setAlpha(0f);
//        selectPositionTitle.setTranslationY(50f);
//        selectPositionTitle.setAlpha(0f);
//        teamTitle.setTranslationX(200f);
//        teamTitle.setAlpha(0f);
//        robotImage.setTranslationX(200f);
//        robotImage.setAlpha(0f);
        firstCard.animate().alpha(1f).translationYBy(-250).setDuration(100).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            secondCard.animate().alpha(1f).translationYBy(-250).setDuration(100).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                titleCard.animate().alpha(1f).translationYBy(500).setDuration(100).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                    title.animate().alpha(1f).translationXBy(100).setDuration(300);
                    info.animate().alpha(1f).translationXBy(100).setDuration(300);
                    cone1.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cone2.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cone3.animate().alpha(1f).translationXBy(-50).setDuration(750);
                    cube1.animate().alpha(1f).translationXBy(50).setDuration(750);
                    cube2.animate().alpha(1f).translationXBy(50).setDuration(750);
                    cube3.animate().alpha(1f).translationXBy(50).setDuration(750);
                    mobilityLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    climbLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    menuLayout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    nextButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
//                        selectPositionTitle.animate().alpha(1f).translationYBy(-50).setDuration(750);
//                        teamTitle.animate().alpha(1f).translationXBy(-200f).setDuration(500);
//                        robotImage.animate().alpha(1f).translationXBy(-200f).setDuration(500);
                }).start();
            }).start();
        }).start();

    }

 */
    public void saveScoutInfo(){
        // TODO: Keyush/Archit: For Saturday. Do the UI -> Model as a model.captureAutonomous()

        if(checkBox1.getId() == firstAutoPickup || checkBox4.getId() == firstAutoPickup){
            wing1 = true;
        }
        else if(checkBox2.getId() == firstAutoPickup || checkBox5.getId() == firstAutoPickup){
            wing2 = true;
        }
        else if(checkBox3.getId() == firstAutoPickup || checkBox6.getId() == firstAutoPickup){
            wing3 = true;
        }
        else if(checkBox7.getId() == firstAutoPickup){
            center1 = true;
        }
        else if(checkBox8.getId() == firstAutoPickup){
            center2 = true;
        }
        else if(checkBox9.getId() == firstAutoPickup){
            center3 = true;
        }
        else if(checkBox10.getId() == firstAutoPickup){
            center4 = true;
        }
        else if(checkBox11.getId() == firstAutoPickup){
            center5 = true;
        }

        model.captureAutoData(
                robotPosition,
                wing1,
                wing2,
                wing3,
                center1,
                center2,
                center3,
                center4,
                center5,
                Integer.parseInt(ampScore.getText().toString()),
                Integer.parseInt(ampMiss.getText().toString()),
                Integer.parseInt(speakerScore.getText().toString()),
                Integer.parseInt(speakerMiss.getText().toString()),
                leaveBool
        );

    }
}
