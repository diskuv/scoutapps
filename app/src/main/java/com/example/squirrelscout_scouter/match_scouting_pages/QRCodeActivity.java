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

public class QRCodeActivity extends ComponentActivity implements View.OnClickListener, ComDataRequestCallback {

    //instances
    private ScoutingSessionViewModel model;
    private Handler uiThreadHandler;
    private SVGImageView qrCode;
    int click;
    Button generate;

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
        qrCode.setVisibility(View.INVISIBLE);

        generate = (Button) findViewById(R.id.generateQR);
        generate.setOnClickListener(this);

        // TODO: Keyush/Archit: For Saturday. Do the Model -> UI.
        // bind view model updates to the UI (partially done with the finishButton visibility,
        // but have not set the notesText on the model)

//        model.getRawMatchDataSession().observe(this, session -> {
//            ModifiableRawMatchDataUiState rawMatchData = session.modifiableRawMatchData();
//        });

    }

    public void onClick(View view){
        int clickedId = view.getId();
        if(clickedId == R.id.NEXT){
            nextPageLogic();
        }
        else if(clickedId == R.id.generateQR && click == 0){
            click++;
            generateQRCode();
        }
    }
    public void nextPageLogic(){
        // Create an Intent to launch the target activity
        Intent intent = new Intent(QRCodeActivity.this, StartScoutingActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        // Start the target activity with the Intent
        startActivity(intent);
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
