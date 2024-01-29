package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.ContentValues;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import androidx.appcompat.app.AppCompatActivity;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStoreOwner;

import com.example.squirrelscout_scouter.MainActivity;
import com.example.squirrelscout_scouter.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class ImageTrial extends ComponentActivity implements View.OnClickListener{
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.heatmap_trial);

        ImageView imageView = findViewById(R.id.imageView);
        Button saveButton = (Button) findViewById(R.id.button);
        saveButton.setOnClickListener(this);



        imageView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int action = event.getActionMasked();

                if (action == MotionEvent.ACTION_DOWN) {
                    // Check if the touch is within the bounds of the ImageView
                    if (isTouchInsideView(event.getRawX(), event.getRawY(), imageView)) {
                        // Add a marker or perform any action you want
                        addMarker(event.getX(), event.getY(), imageView);

                        return true;
                    }
                }

                return false;
            }
        });
    }

    @Override
    public void onClick(View view) {
        int clickedId = view.getId();

        if(clickedId == R.id.button){
            // Save the marked image to the device's gallery
            ImageView imageView = findViewById(R.id.imageView);
            saveImageToGallery(getMarkedImage(imageView), "Marked_Image");
            Toast.makeText(ImageTrial.this, "saved", Toast.LENGTH_SHORT).show();
        }
    }

    private boolean isTouchInsideView(float x, float y, View view) {
        int[] location = new int[2];
        view.getLocationOnScreen(location);

        int viewX = location[0];
        int viewY = location[1];
        int viewWidth = view.getWidth();
        int viewHeight = view.getHeight();

        return (x > viewX && x < (viewX + viewWidth) && y > viewY && y < (viewY + viewHeight));
    }

    private void addMarker(float x, float y, ImageView imageView) {
        // Create a marker (in this example, a red circle)
        Bitmap originalBitmap = getMarkedImage(imageView);
        Bitmap markerBitmap = Bitmap.createBitmap(originalBitmap.getWidth(), originalBitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(markerBitmap);
        canvas.drawBitmap(originalBitmap, 0, 0, null);

        Paint paint = new Paint();
        paint.setColor(Color.RED);
        paint.setStyle(Paint.Style.FILL);
        canvas.drawCircle(x, y, 20, paint); // Adjust the radius as needed

        // Set the marked image with the added marker to the ImageView
        imageView.setImageBitmap(markerBitmap);
    }

    private Bitmap getMarkedImage(ImageView imageView) {
        // Create a bitmap from the ImageView
        Bitmap originalBitmap = Bitmap.createBitmap(imageView.getWidth(), imageView.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(originalBitmap);
        imageView.draw(canvas);

        return originalBitmap;
    }

    private void saveImageToGallery(Bitmap bitmap, String displayName) {
        ContentValues values = new ContentValues();
        values.put(MediaStore.Images.Media.DISPLAY_NAME, displayName);
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
        values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000);

        // Save the image to the Photos (or Gallery) using MediaStore
        try {
            // Use insertImage method to add image to the gallery
            String imageUrl = MediaStore.Images.Media.insertImage(
                    getContentResolver(),
                    bitmap,
                    displayName,
                    "Image with marker"
            );

            // If the insertion was successful, notify the media scanner
            if (imageUrl != null) {
                sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse(imageUrl)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
