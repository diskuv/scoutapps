package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStoreOwner;

import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGImageView;
import com.example.squirrelscout.data.ComDataForegroundListener;
import com.example.squirrelscout.data.ComDataRequestCallback;
import com.example.squirrelscout.data.models.ComDataModel;
import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ui.viewmodels.ModifiableRawMatchDataUiState;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;
import com.example.squirrelscout_scouter.util.ScoutSingleton;

public class QRCodeActivity extends ComponentActivity implements View.OnClickListener {

    //instances
    EditText notesText;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.qrcode_page);

        //Button assignmnet
        ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();
        TextView label = (TextView) findViewById(R.id.textView3);
        label.setText("Match #" + scoutSingleton.getMatchNum() + "\n" + scoutSingleton.getRobotNum());
        Button qrButton = (Button) findViewById(R.id.NEXT);
        qrButton.setOnClickListener(this);
    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.NEXT){
            nextPageLogic();
            Toast.makeText(QRCodeActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
        }
    }
    public void nextPageLogic(){
        // Create an Intent to launch the target activity
        Intent intent = new Intent(QRCodeActivity.this, StartScoutingActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        // Start the target activity with the Intent
        startActivity(intent);
    }
}
