package com.example.squirrelscout_scouter.match_scouting_pages;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Debug;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.util.SharedImageSingleton;

public class PopUpWindow extends AppCompatActivity implements View.OnClickListener {

    //instances
    Button exitButton, scoreButton, missedButton;
    TextView scoreCounter, missedCounter;
    ImageView imageView;
    SharedImageSingleton sharedImageSingleton = SharedImageSingleton.getInstance();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.heatmap_trial);

        //window scene
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        int width = dm.widthPixels;
        int height = dm.heightPixels;
        getWindow().setLayout((int) (width * 0.7), (int) (height * 0.7));
        WindowManager.LayoutParams params = getWindow().getAttributes();
        params.gravity = Gravity.CENTER;
        params.x = 0;
        params.y = -20;
        getWindow().setAttributes(params);

        Button exitButton = (Button) findViewById(R.id.cancel);
        exitButton.setOnClickListener(this);

        scoreButton = (Button) findViewById(R.id.ScoredButton);
        scoreButton.setOnClickListener(this);
        missedButton = (Button) findViewById(R.id.MissedButton);
        missedButton.setOnClickListener(this);
        scoreCounter = (TextView) findViewById(R.id.SuccessCounter);
        scoreCounter.setOnClickListener(this);
        missedCounter = (TextView) findViewById(R.id.MissedCounter);
        missedCounter.setOnClickListener(this);
        imageView = findViewById(R.id.imageView);

        //show updated image
        // Retrieve the marker information from the intent

        // Display the marked image in the ImageView
        imageView.setImageBitmap(sharedImageSingleton.getMarkedImage());
        scoreCounter.setText(sharedImageSingleton.getSuccess() + "");
        missedCounter.setText(sharedImageSingleton.getMiss() + "");
    }

    @Override
    public void onClick(View view) {
        int clickedId = view.getId();

        if(clickedId == R.id.cancel){
            //speaker scoring pop up
            sharedImageSingleton.setScored(2);
            finish();
        }
        else if(clickedId == R.id.ScoredButton){
            scoreLogic();
        }
        else if(clickedId == R.id.MissedButton){
            missedLogic();

        }
    }

    //scoring logic
    private void scoreLogic(){
        //if not selected
        if(scoreButton.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            scoreButton.setTextColor(ContextCompat.getColor(this, R.color.white));
            scoreButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            missedButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            missedButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            sharedImageSingleton.setScored(1);
            sharedImageSingleton.setSuccess();
            finish();
        }
    }

    private void missedLogic(){
        //if not selected
        if(missedButton.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            missedButton.setTextColor(ContextCompat.getColor(this, R.color.white));
            missedButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            scoreButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            scoreButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.lightGrey));
            sharedImageSingleton.setScored(0);
            sharedImageSingleton.setMiss();
            finish();
        }
    }
}
