package com.example.squirrelscout.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.content.Intent;
import android.os.IBinder;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.rule.ServiceTestRule;

import com.example.squirrelscout.data.models.ComDataAndProductionTestModel;
import com.example.squirrelscout.data.objects.toy.Add1;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.junit.runner.RunWith;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class DataInstrumentedTest {
    @Rule
    public TestName name = new TestName();

    @Rule
    public final ServiceTestRule serviceRule = new ServiceTestRule();

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
    public void givenAdd1_whenCall_thenIncremented() throws TimeoutException, InterruptedException {
        ComDataAndProductionTestForegroundService.testName = name.getMethodName();
        Intent dataIntent = new Intent(ApplicationProvider.getApplicationContext(), ComDataAndProductionTestForegroundService.class);

        IBinder binder = serviceRule.bindService(dataIntent);
        assertNotNull(binder);

        CountDownLatch latch = new CountDownLatch(1);
        AtomicInteger ret = new AtomicInteger(-1);
        ((ComDataForegroundService.ComDataBinder) binder).getService().requestData(
                data -> {
                    // do the arithmetic
                    Add1 f = ((ComDataAndProductionTestModel)data).getAdd1();
                    int ret0 = f.directCall(11);

                    // signal we are done
                    latch.countDown();
                    ret.set(ret0);
                }
        );
        assertTrue(latch.await(1, TimeUnit.SECONDS));

        assertEquals(12, ret.get());

        serviceRule.unbindService();
    }
}