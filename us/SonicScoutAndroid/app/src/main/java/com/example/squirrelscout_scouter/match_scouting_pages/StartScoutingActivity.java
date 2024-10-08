package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
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
import com.example.squirrelscout_scouter.util.ScoutSingleton;

import java.util.Locale;

public class StartScoutingActivity extends ComponentActivity implements  View.OnClickListener{

    //instances
    Button incrementMatch, decrementMatch, startButton, backButton;
    EditText chooseMatchI, robotNumberI;
    AutoCompleteTextView dropdown;
    View firstCard, secondCard, topCard;
    TextView title, selectMatchTitle, selectPositionTitle, teamTitle;
    LinearLayout layout;

    String robotPosition, m;
    int match;
    private ScoutingSessionViewModel model;

    ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_scouting);

        // view model scoped to the entire scouting session that starts at StartScoutingActivity
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        // new session
        Intent intent = getIntent();
        model.startNewSessionIfNecessary(
                intent.getLongExtra(ScoutingSessionViewModel.INTENT_INITIAL_LONG_SESSION_NUMBER, 0L),
                intent.getStringExtra(ScoutingSessionViewModel.INTENT_INITIAL_STRING_SCOUT_NAME),
                intent.getShortExtra(ScoutingSessionViewModel.INTENT_INITIAL_SHORT_TEAM_NUMBER, (short) 0));

        //buttons
        incrementMatch = (Button) findViewById(R.id.MATCH_INCREMENT);
        incrementMatch.setOnClickListener(this);
        decrementMatch = (Button) findViewById(R.id.MATCH_DECREMENT);
        decrementMatch.setOnClickListener(this);
        startButton = (Button) findViewById(R.id.START);
        startButton.setOnClickListener(this);
        backButton = (Button) findViewById(R.id.BACK);
        backButton.setOnClickListener(this);

        //others
        chooseMatchI = (EditText) findViewById(R.id.Choose_Match_Input);
        robotNumberI = (EditText) findViewById(R.id.Robot_Number_Input);
        firstCard = (View) findViewById(R.id.view2);
        secondCard = (View) findViewById(R.id.view3);
        topCard = (View) findViewById(R.id.view);
        title = (TextView) findViewById(R.id.textView2);
        layout = (LinearLayout) findViewById(R.id.lay1);
        selectMatchTitle = (TextView) findViewById(R.id.Choose_Match_Label);
        selectPositionTitle = (TextView) findViewById(R.id.Robot_Position_Label);
        teamTitle = (TextView) findViewById(R.id.Robot_Selected);

        //dropdown
        dropdown = findViewById(R.id.dropdown);
        String[] items = new String[]{"Red 1", "Red 2", "Red 3", "Blue 1", "Blue 2", "Blue 3"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
        dropdown.setKeyListener(null);
        dropdown.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dropdown.showDropDown();
                rechooseRobot();
            }
        });

        //animate
        animationStart();

        // bind view model updates to the UI
        model.getRawMatchDataSession().observe(this, session -> {
            ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();
            // TODO: Keyush/Archit: Is this getScoutMatch?
            if(rawMatchData.matchScoutingIsSet())
                chooseMatchI.setText(String.format(Locale.ENGLISH, "%d", rawMatchData.matchScouting()));
            // TODO: Keyush/Archit: Is this getRobotPosition?
            if(rawMatchData.positionScoutingIsSet())
                dropdown.setText(rawMatchData.positionScouting());
        });

        //populate text fields if info available
        if(scoutSingleton.getMatchNum() != -1){
            chooseMatchI.setText(String.valueOf(scoutSingleton.getMatchNum()));
        }
        if(scoutSingleton.getRobotColor() != ""){
            dropdown.setText(String.valueOf(scoutSingleton.getRobotColor()));
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Initialize the dropdown adapter with all options again
        String[] items = new String[]{"Red 1", "Red 2", "Red 3", "Blue 1", "Blue 2", "Blue 3"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
    }

    //button functions
    public void onClick(View view){
        int clickedID = view.getId();
        if(clickedID == R.id.MATCH_INCREMENT){
            matchIncrementLogic();
        }
        else if(clickedID == R.id.MATCH_DECREMENT){
            matchDecrementLogic();
        }
        else if(clickedID == R.id.START){
            animateButton((Button) view);
            startLogic();
        }
        else if(clickedID == R.id.BACK){
            animateButton((Button) view);
            backLogic();
        }
    }

    //match counter logic
    private void matchIncrementLogic() {
        if (chooseMatchI.getText().toString().isEmpty()) {
            chooseMatchI.setText("1");
        } else {
            String matchString = chooseMatchI.getText().toString();
            try {
                match = Integer.parseInt(matchString);
                chooseMatchI.setText(String.valueOf(match + 1));
                //change the button to re choose the robot
                rechooseRobot();
            } catch (NumberFormatException e) {
                // Handle the case where the input string is not a valid integer
                // Display an error message or perform appropriate error handling
                e.printStackTrace();
            }
        }
    }
    private void matchDecrementLogic() {
        if (chooseMatchI.getText().toString().isEmpty()) {
            chooseMatchI.setText("1");
        } else {
            String matchString = chooseMatchI.getText().toString();
            try {
                int match = Integer.parseInt(matchString);
                if(match - 1 < 1){
                    chooseMatchI.setText("1");
                }else{
                    chooseMatchI.setText(String.valueOf(match - 1));
                }
                rechooseRobot();
            } catch (NumberFormatException e) {
                // Handle the case where the input string is not a valid integer
                // Display an error message or perform appropriate error handling
                e.printStackTrace();
            }
        }
    }

    //start scouting logic
    private void startLogic(){
        m = chooseMatchI.getText().toString();
        robotPosition = dropdown.getText().toString();
        String num = robotNumberI.getText().toString();
        //checking if all fields have input
        if(m.isEmpty() || robotPosition.isEmpty() || num.isEmpty()){
            Log.d("d", "name is blank");
            Toast.makeText(StartScoutingActivity.this, "Missing field", Toast.LENGTH_SHORT).show();
            if (m.isEmpty()){
                chooseMatchI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
            if(robotPosition.isEmpty()){
                dropdown.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
            if(num.isEmpty()){
                robotNumberI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
        }
        else if(startButton.getText().toString().equals("Choose Robot")){
            startButton.setText("Start Scouting");
            startButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            startButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
//            model.findRobot();
            Log.d("StartScouting", "Session after finding robot is now: " + model.printSession());
        }
        else {
            new Handler(Looper.getMainLooper()).postDelayed(() -> {

                model.captureMatchRobot(Integer.parseInt(m), robotPosition);
                model.captureScoutingRobotNumber(Integer.parseInt(robotNumberI.getText().toString()));
                scoutSingleton.setRobotNum(Integer.parseInt(robotNumberI.getText().toString()));
                scoutSingleton.setMatchNum(Integer.parseInt(chooseMatchI.getText().toString()));
                scoutSingleton.setRobotColor(dropdown.getText().toString());
                // Create an Intent to launch the target activity
                Intent intent = new Intent(StartScoutingActivity.this, AutonomousActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                // Start the target activity with the Intent
                startActivity(intent);
                Toast.makeText(StartScoutingActivity.this, m, Toast.LENGTH_SHORT).show();
                Toast.makeText(StartScoutingActivity.this, robotPosition, Toast.LENGTH_SHORT).show();
            }, 500);
        }
    }

    //go back home logic
    private void backLogic(){
        Toast.makeText(StartScoutingActivity.this, "going back", Toast.LENGTH_SHORT).show();
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // Create an Intent to launch the target activity
            Intent intent = new Intent(StartScoutingActivity.this, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
        }, 500);
    }

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(150);
        }).start();
    }

    private void animationStart(){
        //animations
        firstCard.setTranslationY(1501);
        firstCard.setAlpha(0f);
        secondCard.setTranslationY(1500);
        secondCard.setAlpha(0f);
        topCard.setTranslationY(-500);
        topCard.setAlpha(0f);
        startButton.setAlpha(0f);
        startButton.setTranslationY(50);
        backButton.setAlpha(0f);
        backButton.setTranslationY(50);
        dropdown.setAlpha(0f);
        dropdown.setTranslationY(50);
        layout.setAlpha(0f);
        layout.setTranslationY(50);
        selectMatchTitle.setAlpha(0f);
        selectMatchTitle.setTranslationY(50);
        title.setAlpha(0f);
        selectPositionTitle.setTranslationY(50f);
        selectPositionTitle.setAlpha(0f);
        teamTitle.setTranslationX(200f);
        teamTitle.setAlpha(0f);
        firstCard.animate().alpha(1f).translationYBy(-1500).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            secondCard.animate().alpha(1f).translationYBy(-1500).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                topCard.animate().alpha(1f).translationYBy(500).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                    startButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    backButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    dropdown.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    layout.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    selectMatchTitle.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    title.animate().alpha(1f).setDuration(300);
                    selectPositionTitle.animate().alpha(1f).translationYBy(-50).setDuration(750);
                    teamTitle.animate().alpha(1f).translationXBy(-200f).setDuration(500);
                }).start();
            }).start();
        }).start();
    }

    public void rechooseRobot(){
        startButton.setText("Choose Robot");
        startButton.setTextColor(ContextCompat.getColor(this, R.color.white));
        startButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
    }
}
