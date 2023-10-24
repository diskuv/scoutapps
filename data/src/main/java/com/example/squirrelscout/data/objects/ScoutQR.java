package com.example.squirrelscout.data.objects;

import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGParseException;
import com.diskuv.dksdk.ffi.java.Clazz;
import com.diskuv.dksdk.ffi.java.Com;
import com.diskuv.dksdk.ffi.java.Method;
import com.diskuv.dksdk.schema.StdSchema;
import com.example.squirrelscout.data.capnp.Schema;

import org.capnproto.MessageBuilder;
import org.capnproto.MessageReader;

import java.io.ByteArrayInputStream;

public class ScoutQR {
    private static Clazz g_clazz;
    private static final Method M_QR_CODE_OF_RAW_MATCH_DATA = Method.ofName("qr_code_of_raw_match_data");
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

    /**
     * Create a QR code for {@link Schema.RawMatchData}.
     * @param rawMatchDataMessage A message built with {@link Schema.RawMatchData#factory}
     * @return an SVG image of the QR code
     */
    public SVG qrCodeOfRawMatchData(MessageBuilder rawMatchDataMessage) {
        /* return: [DATA] */
        MessageReader response = clazz.call(M_QR_CODE_OF_RAW_MATCH_DATA, rawMatchDataMessage);
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
