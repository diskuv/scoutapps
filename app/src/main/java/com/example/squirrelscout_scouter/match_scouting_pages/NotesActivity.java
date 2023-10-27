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

public class NotesActivity extends ComponentActivity implements View.OnClickListener, ComDataRequestCallback {

    //instances
    View topCard, mainCard;
    TextView scoutInfo, pageTitle;
    EditText notesText;
    Button finishButton;
    ImageButton page1, page2;
    private ScoutingSessionViewModel model;
    private Handler uiThreadHandler;
    private SVGImageView qrCode;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.notes_scouting);

        // fields that ideally should be dependency injected
        uiThreadHandler = ((MainApplication) getApplication()).getUiThreadHandler();

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        // route data to ComDataRequestCallback (this)
        ComDataForegroundListener.listen(this, getLifecycle(), this);

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
        qrCode = findViewById(R.id.svgViewQrCode);
        qrCode.setVisibility(View.INVISIBLE);

        // TODO: Keyush/Archit: For Saturday. Do the Model -> UI.
        // bind view model updates to the UI (partially done with the finishButton visibility,
        // but have not set the notesText on the model)

        model.getRawMatchDataSession().observe(this, session -> {
            ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();

            if(rawMatchData.notesIsSet()){
                notesText.setText(rawMatchData.notes());
            }
        });

        // control visibility of the finish button. Only when the session
        // is complete should it be visible.
        finishButton.setVisibility(View.INVISIBLE);
        model.getCompletedRawMatchData().observe(this, completed -> {
            finishButton.setVisibility(completed == null ? View.INVISIBLE : View.VISIBLE);
        });

        //start animation
        animationStart();

    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.NEXT){
            nextPageLogic();
        }
        else if(clickedId == R.id.menu_item_1){
            // Create an Intent to launch the target activity
            Intent intent = new Intent(NotesActivity.this, AutonomousActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
        }
        else if(clickedId == R.id.menu_item_2){
            // Create an Intent to launch the target activity
            Intent intent = new Intent(NotesActivity.this, TeleopActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            startActivity(intent);
        }
    }

    //to-do finish
    public void nextPageLogic(){
        //add data to the database
        //create qr code
        //go to qr code page
        // TODO: Keyush/Archit: For Saturday. Do the UI -> Model as a model.captureNotes()

        model.captureNotes(notesText.getText().toString());

        Toast.makeText(NotesActivity.this, "Creating QR code and going to next page", Toast.LENGTH_SHORT).show();
        Log.i("Notes", "Session as QR code is being created: " + model.printSession());
        model.requestQrCode();
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

    @Override
    public void onComDataReady(ComDataModel data) {
        Log.d("Notes", "onComDataReady");

        uiThreadHandler.post(() ->
            model.getQrRequests().observe(data, completeRawMatchData -> {
                /* Use lifetime-scoped data COM objects */
                SVG svg = model.generateQrCode(data, completeRawMatchData);

                /* Sending data results back to the UI thread */
                uiThreadHandler.post(() -> {
                    qrCode.setSVG(svg);
                    qrCode.setVisibility(View.VISIBLE);
                });
            }));
    }
}
