package com.example.squirrelscout.data.objects.toy;

import com.diskuv.dksdk.ffi.java.Clazz;
import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.Instance;
import com.diskuv.dksdk.ffi.java.Method;
import com.diskuv.dksdk.schema.StdSchema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

public class Multiply {
    private static volatile Clazz clazz;
    private static final Method M_NEW = Method.ofName("new");
    private final Instance instance;

    private Multiply(Instance instance) {
        this.instance = instance;
    }

    public static Multiply create(Com com) {
        /* Init <Clazz> singleton */
        if (clazz == null) {
            synchronized (Multiply.class) {
                if (clazz == null) {
                    clazz = com.borrowClassUntilFinalized("*(uint32 a, uint32 b)");
                }
            }
        }

        MessageBuilder arguments = Com.newMessageBuilder();
        MessageReader returnValue = clazz.call(M_NEW, arguments);
        /* [type GenericReturn = unset | value of 'value | newObject of ComObject]
         * We only need [newObject of ComObject], but we still have to specific
         * something for the ['value] generic type parameter.
         */
        StdSchema.GenericReturn.Reader<StdSchema.Su8.Reader> grReader =
                returnValue.getRoot(StdSchema.GenericReturn.newFactory(StdSchema.Su8.factory));
        StdSchema.ComObject.Reader reader = grReader.getNewObject();
        return new Multiply(clazz.takeInstanceObjectUntilFinalized(reader));
    }

    public byte[] getComObjectBytes() {
        return instance.getComObjectBytes();
    }
}
