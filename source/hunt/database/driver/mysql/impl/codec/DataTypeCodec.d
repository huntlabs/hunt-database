module hunt.database.driver.mysql.impl.codec.DataTypeCodec;

import hunt.database.driver.mysql.impl.codec.DataType;
import hunt.database.driver.mysql.impl.codec.ColumnDefinition;

import hunt.database.driver.mysql.impl.util.BufferUtils;
import hunt.database.base.Numeric;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.net.Exceptions;
import hunt.text.Charset;

import std.conv;
import std.concurrency : initOnce;
import std.variant;

/**
 * 
 */
class DataTypeCodec {
    // binary codec protocol: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html#sect_protocol_binary_resultset_row_value

    // Sentinel used when an object is refused by the data type
    static Object REFUSED_SENTINEL() {
        __gshared Object inst;
        return initOnce!inst(new Object());
    }

    // private static final java.time.format.DateTimeFormatter DATETIME_FORMAT = new DateTimeFormatterBuilder()
    //     .parseCaseInsensitive()
    //     .append(ISO_LOCAL_DATE)
    //     .appendLiteral(' ')
    //     .appendValue(HOUR_OF_DAY, 2)
    //     .appendLiteral(':')
    //     .appendValue(MINUTE_OF_HOUR, 2)
    //     .appendLiteral(':')
    //     .appendValue(SECOND_OF_MINUTE, 2)
    //     .appendFraction(MICRO_OF_SECOND, 0, 6, true)
    //     .toFormatter();

    static Variant decodeText(DataType dataType, Charset charset, int columnDefinitionFlags, ByteBuf buffer) {
        int len = cast(int) BufferUtils.readLengthEncodedInteger(buffer);
        int index = buffer.readerIndex();

        scope(exit) {
            buffer.skipBytes(len);
        }

        bool isBinaryField = isBinaryField(columnDefinitionFlags);

        version(HUNT_DB_DEBUG_MORE) {
            tracef("dataType=%s, index=%d, len=%d, columnDefinitionFlags=%d, isBinaryField=%s", 
                dataType, index, len, columnDefinitionFlags, isBinaryField);
        }

        string value = "";
        if (isBinaryField) {
            byte[] data = textDecodeBlob(index, len, buffer);
            if(data is null) {
                return Variant("");
            } else {
                return Variant(cast(string)data);
            }
        } else {
            value = textDecodeText(charset, index, len, buffer);
        }
        
        version(HUNT_DB_DEBUG_MORE) {
            byte[] d = new byte[len];
            for(int i=0; i< len; i++) {
                d[i] = buffer.getByte(index + i);
            }
            tracef("raw value: %s, bytes: [%(%02X  %)]", value, d);
        }
        // ByteBuf data = buffer.readSlice(length);
        switch (dataType) {
            case DataType.BIT:
                byte v = buffer.getByte(index);
                if(v == 1)  return Variant(true);
                return Variant(false);

            case DataType.INT1:
                return to!(byte)(value).Variant();

            case DataType.INT2:
            case DataType.YEAR:
                return to!short(value).Variant();

            case DataType.INT3:
            case DataType.INT4:
                return to!int(value).Variant();

            case DataType.INT8:
                return to!long(value).Variant();

            case DataType.FLOAT:
                return to!float(value).Variant();

            case DataType.DOUBLE:
                return to!double(value).Variant();

    //         case DataType.NUMERIC:
    //             return textDecodeNUMERIC(charset, data).Variant();
    //         case DataType.DATE:
    //             return textDecodeDate(charset, data).Variant();
    //         case DataType.TIME:
    //             return textDecodeTime(charset, data).Variant();
    //         case DataType.DATETIME:
    //         case DataType.TIMESTAMP:
    //             return textDecodeDateTime(charset, data).Variant();
            case DataType.STRING:
            case DataType.VARSTRING:
            case DataType.BLOB:
            default:
                // if (isBinaryField(columnDefinitionFlags)) {
                //     return textDecodeBlob(index, len, buffer).Variant();
                // } else {
                //     return textDecodeText(charset, index, len, buffer).Variant();
                // }

                return textDecodeText(charset, index, len, buffer).Variant();
        }
    }

    // //TODO take care of unsigned numeric values here?
    static void encodeBinary(DataType dataType, Charset charset, ref Variant value, ByteBuf buffer) {
        switch (dataType) {
            case DataType.INT1:
                byte b = 0;
                if (value.type == typeid(bool)) {
                    if (value.get!bool()) {
                        b = 1;
                    } else {
                        b = 0;
                    }
                } else {
                    assert(value.type == typeid(byte) || value.type == typeid(ubyte));
                    b = value.get!byte();
                }
                buffer.writeByte(b);
                break;

            case DataType.INT2:
                assert(value.type == typeid(short) || value.type == typeid(short));
                buffer.writeShortLE(value.get!short());
                break;

            case DataType.INT3:
                assert(value.type == typeid(int) || value.type == typeid(uint));
                buffer.writeMediumLE(value.get!int());
                break;

            case DataType.INT4:
                assert(value.type == typeid(int) || value.type == typeid(uint));
                buffer.writeIntLE(value.get!int());
                break;

            case DataType.INT8:
                assert(value.type == typeid(long) || value.type == typeid(ulong));
                buffer.writeLongLE(value.get!int());
                break;

            case DataType.FLOAT:
                assert(value.type == typeid(float));
                buffer.writeFloatLE(value.get!float());
                break;

            case DataType.DOUBLE:
                assert(value.type == typeid(int) || value.type == typeid(int));
                buffer.writeDoubleLE(value.get!double());
                break;
    //         case DataType.NUMERIC:
    //             binaryEncodeNumeric(charset, (Numeric) value, buffer);
    //             break;
            case DataType.BLOB:
                assert(value.type == typeid(byte[]) || value.type == typeid(ubyte[]));
                byte[] data = value.get!(byte[])();
                BufferUtils.writeLengthEncodedInteger(buffer, cast(int)data.length);
                buffer.writeBytes(data);
                break;
    //         case DataType.DATE:
    //             binaryEncodeDate((LocalDate) value, buffer);
    //             break;
    //         case DataType.TIME:
    //             binaryEncodeTime((Duration) value, buffer);
    //             break;
    //         case DataType.DATETIME:
    //             binaryEncodeDatetime((LocalDateTime) value, buffer);
    //             break;
            case DataType.STRING:
            case DataType.VARSTRING:
            default:
                // binaryEncodeText(charset, string.valueOf(value), buffer);
                assert(value.type == typeid(string) || value.type == typeid(const(char)[])
                    || value.type == typeid(immutable(char)[]));
                BufferUtils.writeLengthEncodedString(buffer, value.get!string(), charset);
                break;
        }
    }

    static Variant decodeBinary(DataType dataType, Charset charset, int columnDefinitionFlags, ByteBuf buffer) {
        
        switch (dataType) {
            case DataType.INT1:
                return buffer.readByte().Variant();
            case DataType.YEAR:
            case DataType.INT2:
                return buffer.readShortLE().Variant();
            case DataType.INT3:
            case DataType.INT4:
                return buffer.readIntLE().Variant();
            case DataType.INT8:
                return buffer.readLongLE().Variant();
            case DataType.FLOAT:
                return buffer.readFloatLE().Variant();
            case DataType.DOUBLE:
                return buffer.readDoubleLE().Variant();
    //         case DataType.NUMERIC:
    //             return binaryDecodeNumeric(charset, buffer).Variant();
    //         case DataType.DATE:
    //             return binaryDecodeDate(buffer).Variant();
    //         case DataType.TIME:
    //             return binaryDecodeTime(buffer).Variant();
    //         case DataType.DATETIME:
    //         case DataType.TIMESTAMP:
    //             return binaryDecodeDatetime(buffer).Variant();
            case DataType.STRING:
            case DataType.VARSTRING:
            case DataType.BLOB:
            default:
                if (isBinaryField(columnDefinitionFlags)) {
                    return binaryDecodeBlob(buffer).Variant();
                } else {
                    return BufferUtils.readLengthEncodedString(buffer, charset).Variant();
                }
        }
    }

    // static Object prepare(DataType type, Object value) {
    //     switch (type) {
    //         //TODO handle json + unknown?
    //         default:
    //             Class<?> javaType = type.binaryType;
    //             return value is null || javaType.isInstance(value) ? value : REFUSED_SENTINEL;
    //     }
    // }

    // private static void binaryEncodeInt1(Number value, ByteBuf buffer) {
    //     buffer.writeByte(value.byteValue());
    // }

    // private static void binaryEncodeInt2(Number value, ByteBuf buffer) {
    //     buffer.writeShortLE(value.intValue());
    // }

    // private static void binaryEncodeInt3(Number value, ByteBuf buffer) {
    //     buffer.writeMediumLE(value.intValue());
    // }

    // private static void binaryEncodeInt4(Number value, ByteBuf buffer) {
    //     buffer.writeIntLE(value.intValue());
    // }

    // private static void binaryEncodeInt8(Number value, ByteBuf buffer) {
    //     buffer.writeLongLE(value.longValue());
    // }

    // private static void binaryEncodeFloat(Number value, ByteBuf buffer) {
    //     buffer.writeFloatLE(value.floatValue());
    // }

    // private static void binaryEncodeDouble(Number value, ByteBuf buffer) {
    //     buffer.writeDoubleLE(value.doubleValue());
    // }

    // private static void binaryEncodeNumeric(Charset charset, Numeric value, ByteBuf buffer) {
    //     BufferUtils.writeLengthEncodedString(buffer, value.toString(), charset);
    // }

    // private static void binaryEncodeText(Charset charset, string value, ByteBuf buffer) {
    //     BufferUtils.writeLengthEncodedString(buffer, value, charset);
    // }

    // private static void binaryEncodeBlob(Buffer value, ByteBuf buffer) {
    //     BufferUtils.writeLengthEncodedInteger(buffer, value.length());
    //     buffer.writeBytes(value.getByteBuf());
    // }

    // private static void binaryEncodeDate(LocalDate value, ByteBuf buffer) {
    //     buffer.writeByte(4);
    //     buffer.writeShortLE(value.getYear());
    //     buffer.writeByte(value.getMonthValue());
    //     buffer.writeByte(value.getDayOfMonth());
    // }

    // private static void binaryEncodeTime(Duration value, ByteBuf buffer) {
    //     long secondsOfDuration = value.getSeconds();
    //     int nanosOfDuration = value.getNano();
    //     if (secondsOfDuration == 0 && nanosOfDuration == 0) {
    //         buffer.writeByte(0);
    //         return;
    //     }
    //     byte isNegative = 0;
    //     if (secondsOfDuration < 0) {
    //         isNegative = 1;
    //         secondsOfDuration = -secondsOfDuration;
    //     }

    //     int days = (int) (secondsOfDuration / 86400);
    //     int secondsOfADay = (int) (secondsOfDuration % 86400);
    //     int hour = secondsOfADay / 3600;
    //     int minute = ((secondsOfADay % 3600) / 60);
    //     int second = secondsOfADay % 60;

    //     if (nanosOfDuration == 0) {
    //         buffer.writeByte(8);
    //         buffer.writeByte(isNegative);
    //         buffer.writeIntLE(days);
    //         buffer.writeByte(hour);
    //         buffer.writeByte(minute);
    //         buffer.writeByte(second);
    //         return;
    //     }

    //     int microSecond;
    //     if (isNegative == 1 && nanosOfDuration > 0) {
    //         second = second - 1;
    //         microSecond = (1000_000_000 - nanosOfDuration) / 1000;
    //     } else {
    //         microSecond = nanosOfDuration / 1000;
    //     }

    //     buffer.writeByte(12);
    //     buffer.writeByte(isNegative);
    //     buffer.writeIntLE(days);
    //     buffer.writeByte(hour);
    //     buffer.writeByte(minute);
    //     buffer.writeByte(second);
    //     buffer.writeIntLE(microSecond);
    // }

    // private static void binaryEncodeDatetime(LocalDateTime value, ByteBuf buffer) {
    //     int year = value.getYear();
    //     int month = value.getMonthValue();
    //     int day = value.getDayOfMonth();
    //     int hour = value.getHour();
    //     int minute = value.getMinute();
    //     int second = value.getSecond();
    //     int microsecond = value.getNano() / 1000;

    //     // LocalDateTime does not have a zero value of month or day
    //     if (hour == 0 && minute == 0 && second == 0 && microsecond == 0) {
    //         buffer.writeByte(4);
    //         buffer.writeShortLE(year);
    //         buffer.writeByte(month);
    //         buffer.writeByte(day);
    //     } else if (microsecond == 0) {
    //         buffer.writeByte(7);
    //         buffer.writeShortLE(year);
    //         buffer.writeByte(month);
    //         buffer.writeByte(day);
    //         buffer.writeByte(hour);
    //         buffer.writeByte(minute);
    //         buffer.writeByte(second);
    //     } else {
    //         buffer.writeByte(11);
    //         buffer.writeShortLE(year);
    //         buffer.writeByte(month);
    //         buffer.writeByte(day);
    //         buffer.writeByte(hour);
    //         buffer.writeByte(minute);
    //         buffer.writeByte(second);
    //         buffer.writeIntLE(microsecond);
    //     }
    // }

    // private static Byte binaryDecodeInt1(ByteBuf buffer) {
    //     return buffer.readByte();
    // }

    // private static Short binaryDecodeInt2(ByteBuf buffer) {
    //     return buffer.readShortLE();
    // }

    // private static Integer binaryDecodeInt3(ByteBuf buffer) {
    //     return buffer.readIntLE();
    // }

    // private static Integer binaryDecodeInt4(ByteBuf buffer) {
    //     return buffer.readIntLE();
    // }

    // private static Long binaryDecodeInt8(ByteBuf buffer) {
    //     return buffer.readLongLE();
    // }

    // private static Float binaryDecodeFloat(ByteBuf buffer) {
    //     return buffer.readFloatLE();
    // }

    // private static Double binaryDecodeDouble(ByteBuf buffer) {
    //     return buffer.readDoubleLE();
    // }

    // private static Numeric binaryDecodeNumeric(Charset charset, ByteBuf buffer) {
    //     return Numeric.parse(BufferUtils.readLengthEncodedString(buffer, charset));
    // }

    // private static Object binaryDecodeBlobOrText(Charset charset, int columnDefinitionFlags, ByteBuf buffer) {
    //     if (isBinaryField(columnDefinitionFlags)) {
    //         return binaryDecodeBlob(buffer);
    //     } else {
    //         return binaryDecodeText(charset, buffer);
    //     }
    // }

    private static byte[] binaryDecodeBlob(ByteBuf buffer) {
        int len = cast(int) BufferUtils.readLengthEncodedInteger(buffer);
        ByteBuf buff = buffer.copy(buffer.readerIndex(), len);
        buffer.skipBytes(len);
        return buff.getReadableBytes();
    }

    // private static string binaryDecodeText(Charset charset, ByteBuf buffer) {
    //     return BufferUtils.readLengthEncodedString(buffer, charset);
    // }

    // private static LocalDateTime binaryDecodeDatetime(ByteBuf buffer) {
    //     if (buffer.readableBytes() == 0) {
    //         return null;
    //     }
    //     int length = buffer.readByte();
    //     if (length == 0) {
    //         // invalid value '0000-00-00' or '0000-00-00 00:00:00'
    //         return null;
    //     } else {
    //         int year = buffer.readShortLE();
    //         byte month = buffer.readByte();
    //         byte day = buffer.readByte();
    //         if (length == 4) {
    //             return LocalDateTime.of(year, month, day, 0, 0, 0);
    //         }
    //         byte hour = buffer.readByte();
    //         byte minute = buffer.readByte();
    //         byte second = buffer.readByte();
    //         if (length == 11) {
    //             int microsecond = buffer.readIntLE();
    //             return LocalDateTime.of(year, month, day, hour, minute, second, microsecond * 1000);
    //         } else if (length == 7) {
    //             return LocalDateTime.of(year, month, day, hour, minute, second, 0);
    //         }
    //         throw new DecoderException("Invalid Datetime");
    //     }
    // }

    // private static LocalDate binaryDecodeDate(ByteBuf buffer) {
    //     return binaryDecodeDatetime(buffer).toLocalDate();
    // }

    // private static Duration binaryDecodeTime(ByteBuf buffer) {
    //     byte length = buffer.readByte();
    //     if (length == 0) {
    //         return Duration.ZERO;
    //     } else {
    //         bool isNegative = (buffer.readByte() == 1);
    //         int days = buffer.readIntLE();
    //         int hour = buffer.readByte();
    //         int minute = buffer.readByte();
    //         int second = buffer.readByte();
    //         if (isNegative) {
    //             days = -days;
    //             hour = -hour;
    //             minute = -minute;
    //             second = -second;
    //         }

    //         if (length == 8) {
    //             return Duration.ofDays(days).plusHours(hour).plusMinutes(minute).plusSeconds(second);
    //         }
    //         if (length == 12) {
    //             long microsecond = buffer.readUnsignedIntLE();
    //             if (isNegative) {
    //                 microsecond = -microsecond;
    //             }
    //             return Duration.ofDays(days).plusHours(hour).plusMinutes(minute).plusSeconds(second).plusNanos(microsecond * 1000);
    //         }
    //         throw new DecoderException("Invalid time format");
    //     }
    // }

    // private static Byte textDecodeInt1(Charset charset, ByteBuf buffer) {
    //     return Byte.parseByte(buffer.toString(charset));
    // }

    // private static Short textDecodeInt2(Charset charset, ByteBuf buffer) {
    //     return Short.parseShort(buffer.toString(charset));
    // }

    // private static Integer textDecodeInt3(Charset charset, ByteBuf buffer) {
    //     return Integer.parseInt(buffer.toString(charset));
    // }

    // private static Integer textDecodeInt4(Charset charset, ByteBuf buffer) {
    //     return Integer.parseInt(buffer.toString(charset));
    // }

    // private static Long textDecodeInt8(Charset charset, ByteBuf buffer) {
    //     return Long.parseLong(buffer.toString(charset));
    // }

    // private static Float textDecodeFloat(Charset charset, ByteBuf buffer) {
    //     return Float.parseFloat(buffer.toString(charset));
    // }

    // private static Double textDecodeDouble(Charset charset, ByteBuf buffer) {
    //     return Double.parseDouble(buffer.toString(charset));
    // }

    // private static Number textDecodeNUMERIC(Charset charset, ByteBuf buff) {
    //     return Numeric.parse(buff.toString(charset));
    // }

    // private static Object textDecodeBlobOrText(Charset charset, int columnDefinitionFlags, 
    //         int index, int len, ByteBuf buffer) {
    //     if (isBinaryField(columnDefinitionFlags)) {
    //         return textDecodeBlob(buffer);
    //     } else {
    //         return textDecodeText(charset, buffer);
    //     }
    // }

    private static byte[] textDecodeBlob(int index, int len, ByteBuf buffer) {
        ByteBuf buff = buffer.copy(index, len);
        return buff.getReadableBytes();
    }

    private static string textDecodeText(Charset charset, int index, int len, ByteBuf buffer) {
        return buffer.getCharSequence(index, len, charset);
    }

    // private static LocalDate textDecodeDate(Charset charset, ByteBuf buffer) {
    //     CharSequence cs = buffer.toString(charset);
    //     return LocalDate.parse(cs);
    // }

    // private static Duration textDecodeTime(Charset charset, ByteBuf buffer) {
    //     // HH:mm:ss or HHH:mm:ss
    //     string timeString = buffer.toString(charset);
    //     bool isNegative = timeString.charAt(0) == '-';
    //     if (isNegative) {
    //         timeString = timeString.substring(1);
    //     }

    //     string[] timeElements = timeString.split(":");
    //     if (timeElements.length != 3) {
    //         throw new DecoderException("Invalid time format");
    //     }

    //     int hour = Integer.parseInt(timeElements[0]);
    //     int minute = Integer.parseInt(timeElements[1]);
    //     int second = Integer.parseInt(timeElements[2].substring(0, 2));
    //     long nanos = 0;
    //     if (timeElements[2].length() > 2) {
    //         double fractionalSecondsPart = Double.parseDouble("0." ~ timeElements[2].substring(3));
    //         nanos = (long) (1000000000 * fractionalSecondsPart);
    //     }
    //     if (isNegative) {
    //         return Duration.ofHours(-hour).minusMinutes(minute).minusSeconds(second).minusNanos(nanos);
    //     } else {
    //         return Duration.ofHours(hour).plusMinutes(minute).plusSeconds(second).plusNanos(nanos);
    //     }
    // }

    // private static LocalDateTime textDecodeDateTime(Charset charset, ByteBuf buffer) {
    //     CharSequence cs = buffer.toString(charset);
    //     if (cs.equals("0000-00-00 00:00:00")) {
    //         // Invalid datetime will be converted to zero
    //         return null;
    //     }
    //     return LocalDateTime.parse(cs, DATETIME_FORMAT);
    // }

    private static bool isBinaryField(int columnDefinitionFlags) {
        return (columnDefinitionFlags & ColumnDefinitionFlags.BINARY_FLAG) != 0;
    }
}
