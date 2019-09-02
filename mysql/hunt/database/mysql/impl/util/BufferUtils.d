module hunt.database.mysql.impl.util.BufferUtils;

import io.netty.buffer.ByteBuf;

import hunt.text.Charset;

class BufferUtils {
  private static final byte TERMINAL = 0x00;

  static String readNullTerminatedString(ByteBuf buffer, Charset charset) {
    int len = buffer.bytesBefore(TERMINAL);
    String s = buffer.readCharSequence(len, charset).toString();
    buffer.readByte();
    return s;
  }

  static String readFixedLengthString(ByteBuf buffer, int length, Charset charset) {
    return buffer.readCharSequence(length, charset).toString();
  }

  static void writeNullTerminatedString(ByteBuf buffer, CharSequence charSequence, Charset charset) {
    buffer.writeCharSequence(charSequence, charset);
    buffer.writeByte(0);
  }

  static void writeLengthEncodedInteger(ByteBuf buffer, long value) {
    if (value < 251) {
      // 1-byte integer
      buffer.writeByte((byte) value);
    } else if (value <= 0xFFFF) {
      // 0xFC + 2-byte integer
      buffer.writeByte(0xFC);
      buffer.writeShortLE((int) value);
    } else if (value < 0xFFFFFF) {
      // 0xFD + 3-byte integer
      buffer.writeByte(0xFD);
      buffer.writeMediumLE((int) value);
    } else {
      // 0xFE + 8-byte integer
      buffer.writeByte(0xFE);
      buffer.writeLongLE(value);
    }
  }

  static long readLengthEncodedInteger(ByteBuf buffer) {
    short firstByte = buffer.readUnsignedByte();
    switch (firstByte) {
      case 0xFB:
        return -1;
      case 0xFC:
        return buffer.readUnsignedShortLE();
      case 0xFD:
        return buffer.readUnsignedMediumLE();
      case 0xFE:
        return buffer.readLongLE();
      default:
        return firstByte;
    }
  }

  static void writeLengthEncodedString(ByteBuf buffer, String value, Charset charset) {
    byte[] bytes = value.getBytes(charset);
    writeLengthEncodedInteger(buffer, bytes.length);
    buffer.writeBytes(bytes);
  }

  static String readLengthEncodedString(ByteBuf buffer, Charset charset) {
    long length = readLengthEncodedInteger(buffer);
    return readFixedLengthString(buffer, (int) length, charset);
  }
}
