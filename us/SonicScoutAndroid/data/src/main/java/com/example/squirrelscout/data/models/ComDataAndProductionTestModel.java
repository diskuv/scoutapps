package com.example.squirrelscout.data.models;

import android.content.Context;

import com.diskuv.dksdk.ffi.java.Com;
import com.example.squirrelscout.data.objects.toy.Add1;
import com.example.squirrelscout.data.objects.toy.Calculations;
import com.example.squirrelscout.data.objects.toy.Multiply;

/**
 * Class and instance objects for the
 * data layer defined as COM objects, including
 * the DkSDK standard production test objects.
 */
public class ComDataAndProductionTestModel extends ComDataModel {
    private final Add1 add1;
    private final Multiply multiply;
    private final Calculations calculations;

    public ComDataAndProductionTestModel(Com com, Context context, LifecycleRegistrySetter lifecycleSetter) {
        super(com, context, lifecycleSetter);
        this.multiply = Multiply.create(com);
        this.add1 = Add1.create(com);
        this.calculations = Calculations.create(com);
    }

    public Add1 getAdd1() {
        return add1;
    }

    public Multiply getMultiply() {
        return multiply;
    }

    public Calculations getCalculations() {
        return calculations;
    }
}
