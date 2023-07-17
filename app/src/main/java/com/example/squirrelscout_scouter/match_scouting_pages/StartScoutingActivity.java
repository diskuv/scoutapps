package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.PopupMenu;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;

public class StartScoutingActivity extends Activity implements  View.OnClickListener{

    //instances
    Button incrementMatch, decrementMatch, startButton, backButton;
    EditText chooseMatchI;
    AutoCompleteTextView robotPositionI;

    String robotPosition, m;
    int match;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_scouting);

        //buttons
        incrementMatch = (Button) findViewById(R.id.MATCH_INCREMENT);
        incrementMatch.setOnClickListener(this);
        decrementMatch = (Button) findViewById(R.id.MATCH_DECREMENT);
        decrementMatch.setOnClickListener(this);
        startButton = (Button) findViewById(R.id.START);
        startButton.setOnClickListener(this);
        robotPositionI = (AutoCompleteTextView) findViewById(R.id.dropdown);

        //others
        chooseMatchI = (EditText) findViewById(R.id.Choose_Match_Input);

        //dropdown
        AutoCompleteTextView dropdown = findViewById(R.id.dropdown);
        String[] items = new String[]{"Red 1", "Red 2", "Red 3", "Blue 1", "Blue 2", "Blue 3"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.dropdown_text, items);
        dropdown.setAdapter(adapter);
        dropdown.setKeyListener(null);
        dropdown.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dropdown.showDropDown();
            }
        });
    }

    //button functions
    public void onClick(View view){
        animateButton((Button) view);
        int clickedID = view.getId();
        if(clickedID == R.id.MATCH_INCREMENT){
            matchIncrementLogic();
        }
        else if(clickedID == R.id.MATCH_DECREMENT){
            matchDecrementLogic();
        }
        else if(clickedID == R.id.START){
            startLogic();
        }
    }

    private void matchIncrementLogic() {
        if (chooseMatchI.getText().toString().isEmpty()) {
            chooseMatchI.setText("1");
        } else {
            String matchString = chooseMatchI.getText().toString();
            try {
                match = Integer.parseInt(matchString);
                chooseMatchI.setText(String.valueOf(match + 1));
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
            } catch (NumberFormatException e) {
                // Handle the case where the input string is not a valid integer
                // Display an error message or perform appropriate error handling
                e.printStackTrace();
            }
        }
    }

    private void startLogic(){
        m = chooseMatchI.getText().toString();
        robotPosition = robotPositionI.getText().toString();
        if(m.isEmpty() || robotPosition.isEmpty()){
            Log.d("d", "name is blank");
            Toast.makeText(StartScoutingActivity.this, "Missing field", Toast.LENGTH_SHORT).show();
            if (m.isEmpty()){
                chooseMatchI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
            if(robotPosition.isEmpty()){
                robotPositionI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
        }
        else if(startButton.getText().toString().equals("Choose Robot")){
            startButton.setText("Start Scouting");
            startButton.setTextColor(ContextCompat.getColor(this, R.color.black));
        }
        else {
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                //startActivity(new Intent(StartScoutingActivity.this, StartScoutingActivity.class));
                Toast.makeText(StartScoutingActivity.this, m, Toast.LENGTH_SHORT).show();
                Toast.makeText(StartScoutingActivity.this, robotPosition, Toast.LENGTH_SHORT).show();
            }, 500);
        }
    }

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(250).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(250);
        }).start();
    }


}
