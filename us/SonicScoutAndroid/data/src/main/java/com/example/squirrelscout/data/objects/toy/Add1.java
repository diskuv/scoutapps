package com.example.squirrelscout.data.objects.toy;

import com.diskuv.dksdk.ffi.java.Clazz;
import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.Instance;
import com.diskuv.dksdk.ffi.java.Method;
import com.diskuv.dksdk.schema.StdSchema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

public class Add1 {
    private static volatile Clazz clazz;
    private static final Method M_NEW = Method.ofName("new");
    private static final Method M_DK_CALL = Method.ofName("dk_call");
    private final Instance instance;

    private Add1(Instance instance) {
        this.instance = instance;
    }

    public static Add1 create(Com com) {
        /* Init <Clazz> singleton */
        if (clazz == null) {
            synchronized (Add1.class) {
                if (clazz == null) {
                    clazz = com.borrowClassUntilFinalized("+1(uint32 a)");
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
        return new Add1(clazz.takeInstanceObjectUntilFinalized(reader));
    }

    public int directCall(int a) {
        MessageBuilder arguments = Com.newMessageBuilder();
        StdSchema.Su32.Builder argsRoot = arguments.initRoot(StdSchema.Su32.factory);
        argsRoot.setI1(a);

        MessageReader returnValue = instance.call(M_DK_CALL, arguments);
        StdSchema.GenericReturn.Reader<StdSchema.Su32.Reader> grReader =
                returnValue.getRoot(StdSchema.GenericReturn.newFactory(StdSchema.Su32.factory));
        StdSchema.Su32.Reader reader = grReader.getValue();
        return reader.getI1();
    }
}
