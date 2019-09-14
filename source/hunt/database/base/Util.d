/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.base.Util;

import hunt.Byte;
import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;
import hunt.util.TypeUtils;

import std.algorithm;
import std.conv;
import std.variant;


/**
*/
class Util {

    private enum byte ZERO = 0;

    static string readCString(ByteBuf src, Charset charset) {
        int len = src.bytesBefore(ZERO);
        string s = src.readCharSequence(len, charset);
        src.readByte();
        return s;
    }

    static string readCStringUTF8(ByteBuf src) {
        return readCString(src, StandardCharsets.UTF_8);
    }

    static void writeCString(ByteBuf dst, string s, Charset charset) {
        dst.writeCharSequence(s, charset);
        dst.writeByte(0);
    }

    static void writeCString(ByteBuf dst, ByteBuf buf) {
        // Important : won't not change data index
        dst.writeBytes(buf, buf.readerIndex(), buf.readableBytes());
        dst.writeByte(0);
    }

    static void writeCStringUTF8(ByteBuf dst, string s) {
        dst.writeCharSequence(s, StandardCharsets.UTF_8);
        dst.writeByte(0);
    }

    static void writeCString(ByteBuf dst, byte[] bytes) {
        dst.writeBytes(bytes, 0, cast(int)bytes.length);
        dst.writeByte(0);
    }

    static string buildInvalidArgsError(Variant[] values, string[] types) {
        import std.format;
        // string str = types.to!string();
        string str = format("[%-(%s / %)]", types);
        return "Values [" ~ values.map!(v => v.to!string() ~ " : "~ v.type.toString() ).joiner(", ").to!string() ~
            "] cannot be coerced to " ~ str;
    }

    static string buildInvalidArgsError(T)(T[] values, TypeInfo[] types) {
        return "Values [" ~ values.map!(v => v.to!string()).joiner(", ").to!string() ~
            "] cannot be coerced to [" ~ types.map!(t => TypeUtils.getSimpleName(t))
            .joiner(", ").to!string() ~ "]";
    }

    // private enum int FIRST_HALF_BYTE_MASK = 0x0F;

    // static int writeHexString(Buffer buffer, ByteBuf to) {
    //     int len = buffer.length();
    //     for (int i = 0; i < len; i++) {
    //         int b = Byte.toUnsignedInt(buffer.getByte(i));
    //         int firstDigit = b >> 4;
    //         byte firstHexDigit = cast(byte)bin2hex(firstDigit);
    //         int secondDigit = b & FIRST_HALF_BYTE_MASK;
    //         byte secondHexDigit = cast(byte)bin2hex(secondDigit);
    //         to.writeByte(firstHexDigit);
    //         to.writeByte(secondHexDigit);
    //     }
    //     return len;
    // }

    // private static int bin2hex(int digit){
    //     int isLessOrEqual9 =(digit-10)>>31;
    //     //isLessOrEqual9==0xff<->digit<=9
    //     //bin2hexAsciiDistance=digit<=9?48:87;
    //     int bin2hexAsciiDistance = 48+((~isLessOrEqual9)&39);
    //     return digit+bin2hexAsciiDistance;
    // }
}
