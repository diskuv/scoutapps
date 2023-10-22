package com.example.squirrelscout.data;

import com.example.squirrelscout.data.ComDataForegroundService;

/**
 * Same as {@link ComDataForegroundService} except adds
 * the standard production test COM objects.
 */
public class ComDataAndProductionTestForegroundService
    extends ComDataForegroundService {

  protected static String testName;
  protected boolean hasProductionTestObjects() { return true; }

  protected String getLogName() { return testName; }
}
