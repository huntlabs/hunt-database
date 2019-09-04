module hunt.database.mysql.impl.util.BufferUtils;

import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;

class BufferUtils {
    private enum byte TERMINAL = 0x00;

    static string readNullTerminatedString(ByteBuf buffer, Charset charset) {
        int len = buffer.bytesBefore(TERMINAL);
        string s = buffer.readCharSequence(len, charset);
        buffer.readByte();
        return s;
    }

    static string readFixedLengthString(ByteBuf buffer, int length, Charset charset) {
        return buffer.readCharSequence(length, charset);
    }

    static void writeNullTerminatedString(ByteBuf buffer, CharSequence charSequence, Charset charset) {
        buffer.writeCharSequence(charSequence, charset);
        buffer.writeByte(0);
    }

    static void writeLengthEncodedInteger(ByteBuf buffer, long value) {
        if (value < 251) {
            // 1-byte integer
            buffer.writeByte(cast(byte) value);
        } else if (value <= 0xFFFF) {
            // 0xFC + 2-byte integer
            buffer.writeByte(0xFC);
            buffer.writeShortLE(cast(int) value);
        } else if (value < 0xFFFFFF) {
            // 0xFD + 3-byte integer
            buffer.writeByte(0xFD);
            buffer.writeMediumLE(cast(int) value);
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

    static void writeLengthEncodedString(ByteBuf buffer, string value, Charset charset) {
        byte[] bytes = cast(byte[])value; // .getBytes(charset);
        writeLengthEncodedInteger(buffer, cast(int)bytes.length);
        buffer.writeBytes(bytes);
    }

    static string readLengthEncodedString(ByteBuf buffer, Charset charset) {
        long length = readLengthEncodedInteger(buffer);
        return readFixedLengthString(buffer, cast(int) length, charset);
    }
}
