package com.example.squirrelscout.data.objects;

import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGParseException;
import com.diskuv.dksdk.ffi.java.Clazz;
import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.Method;
import com.diskuv.dksdk.schema.StdSchema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

import java.io.ByteArrayInputStream;

public class ScoutQR {
    private static Clazz g_clazz;
    private static final Method M_GENERATE_QR_CODE = Method.ofName("generate");
    private final Clazz clazz;

    private ScoutQR(Clazz clazz) {
        this.clazz = clazz;
    }

    private synchronized static Clazz getClazz(Com com) {
        if (g_clazz == null) {
            g_clazz = com.borrowClassUntilFinalized("SquirrelScout::QR");
        }
        return g_clazz;
    }

    public static ScoutQR create(Com com) {
        return new ScoutQR(getClazz(com));
    }

    public SVG generate(byte[] blob) {
        /* args: [DATA] */
        MessageBuilder arguments = Com.newMessageBuilder();
        StdSchema.Sd.Builder builder = arguments.initRoot(StdSchema.Sd.factory);
        builder.setI1(blob);

        /* return: [DATA] */
        MessageReader response = clazz.call(M_GENERATE_QR_CODE, arguments);
        StdSchema.GenericReturn.Reader<StdSchema.Sd.Reader> grReader =
                response.getRoot(StdSchema.GenericReturn.newFactory(StdSchema.Sd.factory));
        StdSchema.Sd.Reader reader = grReader.getValue();
        byte[] responseBytes = reader.getI1().toArray();

        /* translate to dev-friendly response */
        try {
            return SVG.getFromInputStream(new ByteArrayInputStream(responseBytes));
        } catch (SVGParseException e) {
            throw new RuntimeException(e);
        }
    }
}
