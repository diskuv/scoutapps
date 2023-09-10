package com.example.squirrelscout_scouter.match_scouting_pages;

import android.app.Activity;
import android.content.Intent;
import android.media.Image;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;
import com.google.android.material.textfield.TextInputEditText;

public class NotesActivity extends Activity implements View.OnClickListener{

    //instances
    View topCard, mainCard;
    TextView scoutInfo, pageTitle;
    EditText notesText;
    Button finishButton;
    ImageButton page1, page2;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.notes_scouting);

        //Button assignmnet
        finishButton = (Button) findViewById(R.id.NEXT);
        finishButton.setOnClickListener(this);
        page1 = (ImageButton) findViewById(R.id.menu_item_1);
        page1.setOnClickListener(this);
        page2 = (ImageButton) findViewById(R.id.menu_item_2);
        page2.setOnClickListener(this);

        //...
        topCard = (View) findViewById(R.id.view);
        mainCard = (View) findViewById(R.id.view2);
        scoutInfo = (TextView) findViewById(R.id.textView3);
        pageTitle = (TextView) findViewById(R.id.textView2);
        notesText = (EditText) findViewById(R.id.Name_Input);

        //start animation
        animationStart();
    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.NEXT){
            nextPageLogic();
        }
        else if(clickedId == R.id.menu_item_1){
            startActivity(new Intent(NotesActivity.this, AutonomousActivity.class));
        }
        else if(clickedId == R.id.menu_item_2){
            startActivity(new Intent(NotesActivity.this, TeleopActivity.class));
        }
    }

    //to-do finish
    public void nextPageLogic(){
        //add data to the database
        //create qr code
        //go to qr code page
        Toast.makeText(NotesActivity.this, "Creating QR code and going to next page", Toast.LENGTH_SHORT).show();
    }

    public void animationStart(){
        //animations
        topCard.setAlpha(0);
        topCard.setTranslationY(200);
        mainCard.setAlpha(0);
        mainCard.setTranslationY(200);
        scoutInfo.setAlpha(0);
        scoutInfo.setTranslationX(50);
        pageTitle.setAlpha(0);
        pageTitle.setTranslationX(50);
        notesText.setAlpha(0);
        notesText.setTranslationY(100);
        finishButton.setAlpha(0);
        finishButton.setTranslationY(50);
        mainCard.animate().alpha(1f).translationYBy(-250).setDuration(100).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            topCard.animate().alpha(1f).translationYBy(-250).setDuration(100).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->{
                scoutInfo.animate().alpha(1f).translationXBy(-50).setDuration(150);
                pageTitle.animate().alpha(1f).translationXBy(-50).setDuration(300);
                notesText.animate().alpha(1f).translationYBy(-100).setDuration(750);
                finishButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
            }).start();
        }).start();
    }
}
