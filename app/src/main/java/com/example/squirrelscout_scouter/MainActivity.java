package com.example.squirrelscout_scouter;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    Button button;

    EditText scouterName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        button = findViewById(R.id.button1);

        button.setOnClickListener(this);

        scouterName = findViewById(R.id.scouterName);
    }



    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.button1) {

//            System.out.println("name: " + scouterName.getText());
            startScoutingLogic();
//            Log.d("d", "name: " + scouterName.getText());
        }

    }

    public void startScoutingLogic(){
        if(scouterName.getText().toString().trim().equals("") ){
           Log.d("d", "name is blank");
        } else {
            startActivity(new Intent(MainActivity.this, Page2.class));
            Log.d("d", "scouter name: " + scouterName.getText());
        }
    }
}