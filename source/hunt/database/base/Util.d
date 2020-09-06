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
import hunt.net.buffer.ByteBufUtil;
import hunt.text.Charset;
import hunt.util.TypeUtils;

import std.algorithm;
import std.conv;
import std.variant;

import core.stdc.stdio;
import core.stdc.stdarg;
import core.stdc.time;

import hunt.logging.ConsoleLogger;


/**
 * 
 */
class Util {

    private enum byte ZERO = 0;

    static string readCString(ByteBuf src, Charset charset) {
        string data;
        int len = src.bytesBefore(ZERO);

        version(HUNT_DB_DEBUG_MORE) {
            tracef("len: %d, buffer: %s", len, src);
        }

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


    extern(C) @nogc nothrow {
        static void info(string file = __FILE__, size_t line = __LINE__,
                    string func = __FUNCTION__)(cstring msg) {
            version(Windows) {
                doLog!("info", file, line, func)( msg);
            } else { 
                doLog!("info", CONSOLE_COLOR_BLUE, file, line, func)(msg);
            }
        }

        static void infof(string file = __FILE__, size_t line = __LINE__,
                    string func = __FUNCTION__)(cstring fmt, ...) {
            va_list args;
            va_start(args, fmt);
            char[512] buffer;
            vsnprintf(buffer.ptr, buffer.length, fmt, args);
            version(Windows) {
                doLog!("info", file, line, func)(buffer.ptr);
            } else {
                doLog!("info", CONSOLE_COLOR_BLUE, file, line, func)(buffer.ptr);
            }
            va_end(args);
        }

        version(Windows) {
            static private void doLog(string level, string file = __FILE__, size_t line = __LINE__,
                        string func = __FUNCTION__)(cstring msg) {
                time_t     now;
                tm  ts;
                char[24]       buf;

                // Get current time
                time(&now);

                ts = *localtime(&now);
                strftime(buf.ptr, buf.length, "%m-%d %H:%M:%S", &ts);

                printf("%s.%d | %s | %d | %s | %s | %s:%d\n", buf.ptr, 0, level.ptr, 
                    getTid(), cast(cstring)func.ptr, msg, cast(cstring)file.ptr, line);
            }  

        } else {

            static private void doLog(string level, string leadingColor, string file = __FILE__, size_t line = __LINE__,
                        string func = __FUNCTION__)(cstring msg) {
                time_t     now;
                tm  ts;
                char[24]       buf;

                // Get current time
                time(&now);

                ts = *localtime(&now);
                strftime(buf.ptr, buf.length, "%m-%d %H:%M:%S", &ts);

                version(X86_64) {
                    printf("%s%s.%d | %s | %llu | %s | %s | %s:%llu%s\n", leadingColor.ptr, buf.ptr, 0, level.ptr, 
                        getTid(), cast(cstring)func.ptr, msg, 
                        cast(cstring)file.ptr, line, CONSOLE_COLOR_NONE.ptr);
                } else {
                    printf("%s%s.%d | %s | %u | %s | %s | %s:%u%s\n", leadingColor.ptr, buf.ptr, 0, level.ptr, 
                        getTid(), cast(cstring)func.ptr, msg, 
                        cast(cstring)file.ptr, line, CONSOLE_COLOR_NONE.ptr);
                }
                            
            }

        }
    }
}

private alias cstring = const(char)*;

extern(C) @nogc nothrow : // 


version (Posix) {
    import core.sys.posix.sys.types : pthread_t; 
    size_t syscall(size_t ident, ...);

    ThreadID getTid() {
        version(FreeBSD) {
            long tid;
            enum SYS_thr_self = 432;
            syscall(SYS_thr_self, &tid);
            return cast(ThreadID)tid;
        } else version(OSX) {
            enum SYS_thread_selfid = 372;
            return cast(ThreadID)syscall(SYS_thread_selfid);
        } else version(linux) {
            enum __NR_gettid = 186;
            return cast(ThreadID)syscall(__NR_gettid);
        } else {
            return 0;
        }
    }
    
    // https://misc.flogisoft.com/bash/tip_colors_and_formatting
    // https://solarianprogrammer.com/2019/04/08/c-programming-ansi-escape-codes-windows-macos-linux-terminals/
    // https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences?redirectedfrom=MSDN
    enum CONSOLE_COLOR_NONE = "\033[m";
    enum CONSOLE_COLOR_RED = "\033[0;32;31m";
    enum CONSOLE_COLOR_GREEN = "\033[0;32;32m";
    enum CONSOLE_COLOR_YELLOW = "\033[1;33m";
    enum CONSOLE_COLOR_BLUE = "\033[34m";

    alias ThreadID = pthread_t;

} else {
    
    import core.sys.windows.wincon;
    import core.sys.windows.winbase;
    import core.sys.windows.windef;

    alias ThreadID = uint;

    ThreadID getTid() {
        return GetCurrentThreadId();
    }
}