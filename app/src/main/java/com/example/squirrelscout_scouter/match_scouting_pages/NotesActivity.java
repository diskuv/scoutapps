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
    TextInputEditText notesText;
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

    public void nextPageLogic(){
        Toast.makeText(NotesActivity.this, "Creating QR code and going to next page", Toast.LENGTH_SHORT).show();
    }
}
