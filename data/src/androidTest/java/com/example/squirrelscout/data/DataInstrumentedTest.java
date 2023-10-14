package com.example.squirrelscout.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import android.content.Context;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.android.JavaJdkCompatAndroid;
import com.diskuv.dksdk.ffi.java.compat.JavaJdkCompat;
import com.example.squirrelscout.data.objects.toy.Add1;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.junit.runner.RunWith;

import java.util.logging.Level;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class DataInstrumentedTest {
    @Rule
    public TestName name = new TestName();

    private static final JavaJdkCompat COMPAT = JavaJdkCompatAndroid.createWithDkSDK("datalib");

    @Test
    public void useAppContext() {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        assertEquals("com.example.squirrelscout.data.test", appContext.getPackageName());
    }

    /**
     * This tests calling the "dk_call" method from Java to the C "Add1" instance object.
     * It exercises the <strong>Java instance method call</strong>.
     */
    @Test
    public void givenAdd1_whenCall_thenIncremented() {
        // Initialize Android logging
        COMPAT.getCLib().dksdk_ffi_c_log_configure_android(name.getMethodName(), Level.FINEST);

        Com com = Com.createForUnitTesting(COMPAT);
        assertNotNull(com);

        Add1 f = Add1.create(com);

        int ret = f.directCall(11);

        assertEquals(12, ret);

        com.shutdown();
    }

}