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
    TextView ampTitle;
    Button ampScoreIncrement, ampScoreDecrement, ampMissIncrement, ampMissDecrement;
    TextView ampMissLabel, ampScoreLabel;
    //Breakdown
    AutoCompleteTextView dropdown;
    //Pickup Location
    Button groundButton, sourceButton;
    //Defense
    SeekBar defense;
    //Endgame
    Button parkYes, parkNo, trapYes, trapNo;
    AutoCompleteTextView dropdown2;
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
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        //...
        speakerTitle = (TextView) findViewById(R.id.SpeakerTitle);
        speakerTitle.setOnClickListener(this);
        fieldMap = (ImageView) findViewById(R.id.imageView);
        fieldMap.setOnClickListener(this);
        ampTitle = (TextView) findViewById(R.id.AmpTitle);
        ampTitle.setOnClickListener(this);
        ampScoreIncrement = (Button) findViewById(R.id.Amp_Score_Increment);
        ampScoreIncrement.setOnClickListener(this);
        ampScoreDecrement = (Button) findViewById(R.id.Amp_Missed_Decrement);
        ampScoreDecrement.setOnClickListener(this);
        ampMissIncrement = (Button) findViewById(R.id.Amp_Missed_Increment);
        ampMissIncrement.setOnClickListener(this);
        ampMissDecrement = (Button) findViewById(R.id.Amp_Missed_Decrement);
        ampMissDecrement.setOnClickListener(this);
        ampMissLabel = (TextView) findViewById(R.id.AmpMissedLabel);
        ampMissLabel.setOnClickListener(this);
        ampScoreLabel = (TextView) findViewById(R.id.AmpScoredLabel);
        ampScoreLabel.setOnClickListener(this);

        //Breakdown dropdown
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

        //Buttons
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);

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
            Intent intent = new Intent(TeleopActivity.this, AutonomousActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
        }
        else if(clickedId == R.id.DEFENSE_YES){
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
//        else if(clickedId == R.id.CONE_LOW_INCREMENT){
//            counterIncrementLogic(coneLow);
//        }
//        else if(clickedId == R.id.CONE_LOW_DECREMENT){
//            counterDecrementLogic(coneLow);
//        }
//        else if(clickedId == R.id.CUBE_HIGH_INCREMENT){
//            counterIncrementLogic(cubeHigh);
//        }
//        else if(clickedId == R.id.CUBE_HIGH_DECREMENT){
//            counterDecrementLogic(cubeHigh);
//        }
//        else if(clickedId == R.id.CUBE_MID_INCREMENT){
//            counterIncrementLogic(cubeMid);
//        }
//        else if(clickedId == R.id.CUBE_MID_DECREMENT){
//            counterDecrementLogic(cubeMid);
//        }
//        else if(clickedId == R.id.CUBE_LOW_INCREMENT){
//            counterIncrementLogic(cubeLow);
//        }
//        else if(clickedId == R.id.CUBE_LOW_DECREMENT){
//            counterDecrementLogic(cubeLow);
//        }
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
            incapBool = true;
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
            incapBool = false;
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
            saveScoutInfo();
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
