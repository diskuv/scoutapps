package com.example.squirrelscout_scouter;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGImageView;
import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.ComDataForegroundListener;
import com.example.squirrelscout.data.ComDataRequestCallback;
import com.example.squirrelscout.data.capnp.Schema;
import com.example.squirrelscout.data.models.ComDataModel;
import com.example.squirrelscout_scouter.match_scouting_pages.StartScoutingActivity;

import org.capnproto.MessageBuilder;

public class MainActivity extends AppCompatActivity implements View.OnClickListener, ComDataRequestCallback {
    private Handler uiThreadHandler;

    //instances
    Button startScoutingButton, pitScouting, history, sharePitScouting, nukeData;
    View firstCard, secondCard;
    EditText scouterNameI, teamNameI;
    TextView title, titleSecondary, nameText, teamText;
    private SVGImageView qrCode;

    //variables
    String ScoutName, TeamNum;

    //singleton
    public ScoutInfo scoutInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        // fields that ideally should be dependency injected
        uiThreadHandler = ((MainApplication) getApplication()).getUiThreadHandler();

        // route data to ComDataRequestCallback (this)
        ComDataForegroundListener.listen(this, getLifecycle(), this);

        //buttons
        startScoutingButton = findViewById(R.id.START_SCOUTING);
        startScoutingButton.setOnClickListener(this);
        pitScouting = findViewById(R.id.PIT_SCOUTING);
        pitScouting.setOnClickListener(this);
        history = findViewById(R.id.HISTORY);
        history.setOnClickListener(this);
        sharePitScouting = findViewById(R.id.SHARE_PIT_SCOUTING);
        sharePitScouting.setOnClickListener(this);
        nukeData = findViewById(R.id.NUKE_DATA);
        nukeData.setOnClickListener(this);

        //others
        scouterNameI = findViewById(R.id.Name_Input);
        teamNameI = findViewById(R.id.TeamNum_Input);
        title = findViewById(R.id.textView2);
        titleSecondary = findViewById(R.id.textView3);
        teamText = findViewById(R.id.TeamNum_Label);
        nameText = findViewById(R.id.Name_Label);
        firstCard = findViewById(R.id.view2);
        secondCard = findViewById(R.id.view3);
        qrCode = findViewById(R.id.svgViewQrCode);

        //start animation
        animationStart();

        //load info if created
        scoutInfo = ScoutInfo.getInstance();
        loadScoutInfo();

    }

    @Override
    public void onClick(View view) {
        animateButton((Button) view);
        int clickedID = view.getId();
        Log.d("d", "button clicked");

        if (clickedID == R.id.START_SCOUTING) {
            startScoutingLogic();
        } else if (clickedID == R.id.PIT_SCOUTING) {
            startPitScoutingLogic();
        } else if (clickedID == R.id.SHARE_PIT_SCOUTING) {
            sharePitScouting();
        } else if (clickedID == R.id.HISTORY) {
            startHistorylogic();
        } else if (clickedID == R.id.NUKE_DATA) {
            nukeDataLogic();
        }

    }


    public void startScoutingLogic() {
        ScoutName = scouterNameI.getText().toString();
        TeamNum = teamNameI.getText().toString();
        if (ScoutName.isEmpty() || TeamNum.isEmpty()) {
            Log.d("d", "name is blank");
            Toast.makeText(MainActivity.this, "Missing field", Toast.LENGTH_SHORT).show();
            if (ScoutName.isEmpty()) {
                scouterNameI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
            if (TeamNum.isEmpty()) {
                teamNameI.setHintTextColor(ContextCompat.getColor(this, R.color.error));
            }
        } else {
            uiThreadHandler.postDelayed(() -> {
                saveScoutData();
                startActivity(new Intent(MainActivity.this, StartScoutingActivity.class));
                Log.d("d", "scouter name: " + ScoutName);
                Toast.makeText(MainActivity.this, ScoutName, Toast.LENGTH_SHORT).show();
                Toast.makeText(MainActivity.this, TeamNum, Toast.LENGTH_SHORT).show();
            }, 250);
        }
    }

    private void startPitScoutingLogic() {

    }

    private void sharePitScouting() {

    }

    private void startHistorylogic() {

    }

    private void nukeDataLogic() {
        Toast.makeText(MainActivity.this, "Data Nuked", Toast.LENGTH_SHORT).show();
    }

    private void animationStart() {
        //animations
        firstCard.setTranslationY(1500);
        firstCard.setAlpha(0f);
        secondCard.setTranslationY(1500);
        secondCard.setAlpha(0f);
        startScoutingButton.setAlpha(0f);
        startScoutingButton.setTranslationY(50);
        history.setAlpha(0f);
        history.setTranslationY(50);
        pitScouting.setAlpha(0f);
        pitScouting.setTranslationY(50);
        sharePitScouting.setAlpha(0f);
        sharePitScouting.setTranslationY(50);
        nukeData.setAlpha(0f);
        nukeData.setTranslationY(50);
        title.setTranslationX(-200f);
        title.setAlpha(0f);
        titleSecondary.setTranslationX(-200f);
        titleSecondary.setAlpha(0f);
        nameText.setTranslationX(200f);
        nameText.setAlpha(0f);
        teamText.setTranslationX(200f);
        teamText.setAlpha(0f);
        scouterNameI.setTranslationX(200f);
        scouterNameI.setAlpha(0f);
        teamNameI.setTranslationX(200f);
        teamNameI.setAlpha(0f);
        firstCard.animate().alpha(1f).translationYBy(-1500).setDuration(300).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->
            secondCard.animate().alpha(1f).translationYBy(-1500).setDuration(300).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
                startScoutingButton.animate().alpha(1f).translationYBy(-50).setDuration(750);
                history.animate().alpha(1f).translationYBy(-50).setDuration(750);
                pitScouting.animate().alpha(1f).translationYBy(-50).setDuration(750);
                sharePitScouting.animate().alpha(1f).translationYBy(-50).setDuration(750);
                nukeData.animate().alpha(1f).translationYBy(-50).setDuration(750);
                title.animate().alpha(1f).translationXBy(200f).setDuration(300);
                titleSecondary.animate().alpha(1f).translationXBy(200f).setDuration(750);
                nameText.animate().alpha(1f).translationXBy(-200f).setDuration(500);
                teamText.animate().alpha(1f).translationXBy(-200f).setDuration(500);
                teamNameI.animate().alpha(1f).translationXBy(-200f).setDuration(500);
                scouterNameI.animate().alpha(1f).translationXBy(-200f).setDuration(500);
        }).start()).start();
    }

    //user response button
    private void animateButton(Button button) {
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(150).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() ->
                button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(150)).start();
    }

    //loads the info of the scout if already known
    public void loadScoutInfo() {
        if (scoutInfo.getScoutName() != null) {
            scouterNameI.setText(scoutInfo.getScoutName());
        }
        if (scoutInfo.getScoutTeam() != -1) {
            teamNameI.setText(scoutInfo.getScoutTeam());
        }
    }

    //save data
    public void saveScoutData() {
        scoutInfo.setScoutTeam(Integer.parseInt(TeamNum));
        scoutInfo.setScoutName(ScoutName);
    }

    @Override
    public void onComDataReady(ComDataModel data) {
        /* Use data COM object */
        MessageBuilder rawMatchData = Com.newMessageBuilder();
        Schema.RawMatchData.Builder builder = rawMatchData.initRoot(Schema.RawMatchData.factory);
        builder.setNotes("hello squirrel scouters!");
        SVG svg = data.getScoutQR().qrCodeOfRawMatchData(rawMatchData);

        /* Sending data results back to the UI thread */
        uiThreadHandler.post(() -> qrCode.setSVG(svg));
    }
}