package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
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

import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ScoutInfo;
import com.example.squirrelscout_scouter.ui.viewmodels.ModifiableRawMatchDataUiState;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;

public class TeleopActivity extends ComponentActivity implements View.OnClickListener {

    //instances
    Button coneHi, coneHd, coneMi, coneMd, coneLi, coneLd, cubeHi, cubeHd, cubeMi, cubeMd, cubeLi, cubeLd;
    Button yesDefense, noDefense, yesIncap, noIncap,nextButton;
    ImageButton backPage, notesPage;
    TextView coneHigh, coneMid, coneLow, cubeHigh, cubeMid, cubeLow, info, title;
    AutoCompleteTextView dropdown;
    View titleCard, firstCard, secondCard, mainCard;
    LinearLayout cone1, cone2, cone3, cube1, cube2, cube3, defenseLayout, incapLayout, menuLayout, climbLayout;

    //variables
    boolean defenseBool, incapBool;

//    ScoutInfo scoutInfo;

    private ScoutingSessionViewModel model;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.teleop_scouting);

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

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
        defenseLayout = (LinearLayout) findViewById(R.id.linearLayout7);
        incapLayout = (LinearLayout) findViewById(R.id.linearLayout8);
        climbLayout = (LinearLayout) findViewById(R.id.linearLayout9);
        menuLayout = (LinearLayout) findViewById(R.id.linearLayout10);


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
            startActivity(new Intent(TeleopActivity.this, AutonomousActivity.class));
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
}
