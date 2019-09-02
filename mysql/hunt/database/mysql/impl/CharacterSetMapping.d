module hunt.database.mysql.impl.CharacterSetMapping;


import hunt.text.Charset;
import hunt.collection.HashMap;
import hunt.collection.Map;

import std.string;

final class CharacterSetMapping {
    // private static IntObjectMap!(Charset) byteToCharsetMapping = new IntObjectHashMap<>();
    // private static Map!(string, Integer) stringToByteMapping = new HashMap<>();
    private enum Charset[int] byteToCharsetMapping = [33 : StandardCharsets.UTF_8];
    private enum int[string] stringToByteMapping = ["UTF-8" : 33];

    // static {
    //     byteToCharsetMapping.put(33, StandardCharsets.UTF_8);

    //     // use uppercase representation
    //     stringToByteMapping.put("UTF-8",  33);
    // }

    static Charset getCharset(byte value) {
        return byteToCharsetMapping[value];
    }

    static byte getCharsetByteValue(string charset) {
        return cast(byte)stringToByteMapping[charset.toUpper()];
    }

    static Charset getCharset(string value) {
        return getCharset(getCharsetByteValue(value));
    }
}
