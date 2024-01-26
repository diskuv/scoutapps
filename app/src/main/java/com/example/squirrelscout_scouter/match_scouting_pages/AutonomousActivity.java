package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStoreOwner;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ui.viewmodels.ModifiableRawMatchDataUiState;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;

public class AutonomousActivity extends ComponentActivity implements View.OnClickListener {

    //instances
    Button coneHi, coneHd, coneMi, coneMd, coneLi, coneLd, cubeHi, cubeHd, cubeMi, cubeMd, cubeLi, cubeLd;
    Button yesMobility, noMobility, nextButton;
    ImageButton homeButton, notesButton;
    TextView coneHigh, coneMid, coneLow, cubeHigh, cubeMid, cubeLow, info, title;
    AutoCompleteTextView dropdown;
    View titleCard, firstCard, secondCard, mainCard;
    LinearLayout cone1, cone2, cone3, cube1, cube2, cube3, mobilityLayout, climbLayout, menuLayout;

//    ScoutInfo scoutInfo;

    //variables
    boolean mobilityBool;

    private ScoutingSessionViewModel model;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
            setContentView(R.layout.autonomous_scouting);

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

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
        coneHi = (Button) findViewById(R.id.Amp_Score_Increment);
        coneHi.setOnClickListener(this);
        coneHd = (Button) findViewById(R.id.Amp_Score_Decrement);
        coneHd.setOnClickListener(this);
        coneMi = (Button) findViewById(R.id.Amp_Missed_Increment);
        coneMi.setOnClickListener(this);
        coneMd = (Button) findViewById(R.id.Amp_Missed_Decrement);
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
        titleCard = (View) findViewById(R.id.view);
        mainCard = (View) findViewById(R.id.view2);
        firstCard = (View) findViewById(R.id.view3);
        secondCard = (View) findViewById(R.id.view4);
        title = (TextView) findViewById(R.id.textView2);
        cone1 = (LinearLayout) findViewById(R.id.linearLayout1);
        cone2 = (LinearLayout) findViewById(R.id.linearLayout2);
        cone3 = (LinearLayout) findViewById(R.id.linearLayout3);
        cube1 = (LinearLayout) findViewById(R.id.linearLayout4);
        cube2 = (LinearLayout) findViewById(R.id.linearLayout5);
        cube3 = (LinearLayout) findViewById(R.id.linearLayout6);
        mobilityLayout = (LinearLayout) findViewById(R.id.linearLayout7);
        climbLayout = (LinearLayout) findViewById(R.id.linearLayout8);
        menuLayout = (LinearLayout) findViewById(R.id.linearLayout9);

        //counters
        coneHigh = (TextView) findViewById(R.id.AmpScoredCounter);
        coneMid = (TextView) findViewById(R.id.AmpMissedCounter) ;
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

        // TODO: Keyush/Archit: For Saturday. Do the Model -> UI, and remove scoutInfo.
        // bind view model updates to the UI
        model.getRawMatchDataSession().observe(this, session -> {
            ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

            if(rawMatchData.mobilityIsSet()){
                if(rawMatchData.mobility()){
                    mobilityYesLogic();
                } else {
                    mobilityNoLogic();
                }
            }

            if(rawMatchData.autoClimbIsSet()){
                dropdown.setText(rawMatchData.autoClimb());
            }

            if(rawMatchData.coneHighAIsSet()) {
                coneHigh.setText(String.valueOf(rawMatchData.coneHighA()));
            }

            if(rawMatchData.coneMidAIsSet()){
                coneMid.setText(String.valueOf(rawMatchData.coneMidA()));
            }

            if(rawMatchData.coneLowAIsSet()) {
                coneLow.setText(String.valueOf( rawMatchData.coneLowA()));
            }

        });

        //start animation
        animationStart();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Initialize the dropdown adapter with all options again
        String[] items = new String[]{"Docked", "Engaged", "No Attempt"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.menu_item_1){
            saveScoutInfo();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(AutonomousActivity.this, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
        }
        else if(clickedId == R.id.menu_item_2){
            saveScoutInfo();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(AutonomousActivity.this, NotesActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
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
        else if(clickedId == R.id.Amp_Score_Increment){
            counterIncrementLogic(coneHigh);
        }
        else if(clickedId == R.id.Amp_Score_Decrement){
            counterDecrementLogic(coneHigh);
        }
        else if(clickedId == R.id.Amp_Missed_Increment){
            counterIncrementLogic(coneMid);
        }
        else if(clickedId == R.id.Amp_Missed_Decrement){
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
            saveScoutInfo();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(AutonomousActivity.this, TeleopActivity.class);
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

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(250).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(250);
        }).start();
    }

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

    public void saveScoutInfo(){
        // TODO: Keyush/Archit: For Saturday. Do the UI -> Model as a model.captureAutonomous()

        model.captureAutoData(
                mobilityBool,
                dropdown.getText().toString(),
                Integer.parseInt(coneHigh.getText().toString()),
                Integer.parseInt(coneMid.getText().toString()),
                Integer.parseInt(coneLow.getText().toString()),
                Integer.parseInt(cubeHigh.getText().toString()),
                Integer.parseInt(cubeMid.getText().toString()),
                Integer.parseInt(cubeLow.getText().toString())

        );

    }
}
