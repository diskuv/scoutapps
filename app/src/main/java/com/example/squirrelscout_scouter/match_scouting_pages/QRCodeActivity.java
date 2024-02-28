package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
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
import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ui.viewmodels.ModifiableRawMatchDataUiState;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;
import com.example.squirrelscout_scouter.util.ScoutSingleton;

public class QRCodeActivity extends ComponentActivity implements View.OnClickListener, ComDataRequestCallback {

    //instances
    private ScoutingSessionViewModel model;
    private Handler uiThreadHandler;
    private SVGImageView qrCode;
    int click;
    Button generate;

    ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        click = 0;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.qrcode_page);

        //qrcode....
        // fields that ideally should be dependency injected
        uiThreadHandler = ((MainApplication) getApplication()).getUiThreadHandler();

        // view model
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        // route data to ComDataRequestCallback (this)
        ComDataForegroundListener.listen(this, getLifecycle(), this);

        //Button assignmnet
        ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();
        TextView label = (TextView) findViewById(R.id.textView3);
        label.setText("Match #" + scoutSingleton.getMatchNum() + "\n" + scoutSingleton.getRobotNum());
        Button qrButton = (Button) findViewById(R.id.NEXT);
        qrButton.setOnClickListener(this);
        qrCode = findViewById(R.id.svgViewQrCode2);

        // control visibility of the QR code button. Only when the session
        // is complete should it be visible.
        qrCode.setVisibility(View.INVISIBLE);
        model.getCompletedRawMatchData().observe(this, completed -> {
            qrCode.setVisibility(completed == null ? View.INVISIBLE : View.VISIBLE);
        });

        generate = (Button) findViewById(R.id.generateQR);
        generate.setOnClickListener(this);

    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.NEXT && click != 0){
            nextPageLogic();
        }
        else if(clickedId == R.id.generateQR && click == 0){
            click++;
            generateQRCode();
        }
    }
    public void nextPageLogic(){
        // Create an Intent to launch the target activity
        uiThreadHandler.postDelayed(() -> {
            Intent intent = new Intent(QRCodeActivity.this, StartScoutingActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.putExtra(ScoutingSessionViewModel.INTENT_INITIAL_LONG_SESSION_NUMBER, scoutSingleton.getSn());
            intent.putExtra(ScoutingSessionViewModel.INTENT_INITIAL_STRING_SCOUT_NAME, scoutSingleton.getScoutName());
            intent.putExtra(ScoutingSessionViewModel.INTENT_INITIAL_SHORT_TEAM_NUMBER, scoutSingleton.getValTN());
            // Start the target activity with the Intent
            startActivity(intent);
        }, 250);
    }

    public void generateQRCode(){
        Toast.makeText(QRCodeActivity.this, "Creating QR code and going to next page", Toast.LENGTH_SHORT).show();
        Log.i("Notes", "Session as QR code is being created: " + model.printSession());
        model.requestQrCode();
    }

    @Override
    public void onComDataReady(ComDataModel data) {
        Log.d("QRCode", "onComDataReady");

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
