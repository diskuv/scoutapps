package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
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
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;

public class AutonomousActivity extends Activity implements View.OnClickListener {

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
            setContentView(R.layout.autonomous_scouting);

        //dropdown
        AutoCompleteTextView dropdown = findViewById(R.id.dropdown);
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
    }

    public void onClick(View view){

    }
}
