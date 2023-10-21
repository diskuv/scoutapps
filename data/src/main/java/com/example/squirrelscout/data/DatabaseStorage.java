package com.example.squirrelscout.data;

import static android.os.storage.StorageManager.ACTION_MANAGE_STORAGE;

import android.content.Context;
import android.content.Intent;
import android.os.storage.StorageManager;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class DatabaseStorage {
    // App needs 1 MB within internal storage.
    private static final long NUM_BYTES_NEEDED_FOR_MY_APP = 1024 * 1024L;

    /**
     * Get the sqlite database path.
     *
     * @return the sqlite database path, or null if there is not enough space.
     */
    public static File databasePath(Context context) throws IOException {
        /*
          <a href="https://developer.android.com/training/data-storage/app-specific#query-free-space">Query free space</a>

          Needs to be built for Android Oreo (8.0), aka. API 26+, to check.
         */
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            StorageManager storageManager =
                    context.getSystemService(StorageManager.class);
            UUID appSpecificInternalDirUuid = storageManager.getUuidForPath(context.getFilesDir());
            long availableBytes =
                    storageManager.getAllocatableBytes(appSpecificInternalDirUuid);
            if (availableBytes >= NUM_BYTES_NEEDED_FOR_MY_APP) {
                storageManager.allocateBytes(
                        appSpecificInternalDirUuid, NUM_BYTES_NEEDED_FOR_MY_APP);
            } else {
                // To request that the user remove all app cache files instead, set
                // "action" to ACTION_CLEAR_APP_CACHE.
                Intent storageIntent = new Intent();
                storageIntent.setAction(ACTION_MANAGE_STORAGE);
                return null;
            }
        }

        return new File(context.getFilesDir(), "data.db");
    }
}
