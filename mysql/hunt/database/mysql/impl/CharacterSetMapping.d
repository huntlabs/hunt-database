module hunt.database.mysql.impl.CharacterSetMapping;

import io.netty.util.collection.IntObjectHashMap;
import io.netty.util.collection.IntObjectMap;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

final class CharacterSetMapping {
  private static IntObjectMap!(Charset) byteToCharsetMapping = new IntObjectHashMap<>();
  private static Map!(String, Integer) stringToByteMapping = new HashMap<>();

  static {
    byteToCharsetMapping.put(33, StandardCharsets.UTF_8);

    // use uppercase representation
    stringToByteMapping.put("UTF-8",  33);
  }

  static Charset getCharset(byte value) {
    return byteToCharsetMapping.get(value);
  }

  static byte getCharsetByteValue(String charset) {
    return stringToByteMapping.get(charset.toUpperCase()).byteValue();
  }

  static Charset getCharset(String value) {
    return getCharset(getCharsetByteValue(value));
  }
}
