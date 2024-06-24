package com.example.squirrelscout.data.objects.toy;

import com.diskuv.dksdk.ffi.java.Clazz;
import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.Method;
import com.diskuv.dksdk.schema.StdSchema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

public class Calculations {
    private static volatile Clazz clazz;
    private static final Method M_APPLY_F_3_7 = Method.ofName("apply(f,3,7)");

    private Calculations() {
    }

    public static Calculations create(Com com) {
        /* Init <Clazz> singleton */
        if (clazz == null) {
            synchronized (Multiply.class) {
                if (clazz == null) {
                    clazz = com.borrowClassUntilFinalized("ToyCalculations");
                }
            }
        }

        return new Calculations();
    }

    public int apply_f_3_7(byte[] comObjectBytes) {
        MessageBuilder messageBuilder = Com.newMessageBuilder();
        StdSchema.ComObject.Builder argsRoot = messageBuilder.initRoot(StdSchema.ComObject.factory);
        argsRoot.setI1(comObjectBytes);

        MessageReader retval = clazz.call(M_APPLY_F_3_7, messageBuilder);
        /* [type GenericReturn = unset | value of 'value | newObject of ComObject]
         * We want need [value of Su32] */
        StdSchema.GenericReturn.Reader<StdSchema.Su32.Reader> grReader =
                retval.getRoot(StdSchema.GenericReturn.newFactory(StdSchema.Su32.factory));
        StdSchema.Su32.Reader retvalRoot = grReader.getValue();
        return retvalRoot.getI1();
    }
}
