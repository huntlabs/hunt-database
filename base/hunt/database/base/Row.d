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
module hunt.database.base.Row;

import hunt.database.base.Tuple;

// import java.math.BigDecimal;
// import java.time.*;
// import java.time.temporal.Temporal;
// import java.util.UUID;

import std.variant;


interface Row : Tuple {

    /**
     * Get a column name at {@code pos}.
     *
     * @param pos the column position
     * @return the column name or {@code null}
     */
    string getColumnName(int pos);

    /**
     * Get a column position for the given column {@code name}.
     *
     * @param name the column name
     * @return the column name or {@code -1} if not found
     */
    int getColumnIndex(string name);
    
    /**
     * Get an object value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    Variant getValue(string name);
    alias getValue = Tuple.getValue;

    /**
     * Get a boolean value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    bool getBoolean(string name);
    alias getBoolean = Tuple.getBoolean;


    /**
     * Get a short value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    short getShort(string name);
    alias getShort = Tuple.getShort;

    /**
     * Get an integer value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    int getInteger(string name);
    alias getInteger = Tuple.getInteger;

    /**
     * Get a long value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    long getLong(string name);
    alias getLong = Tuple.getLong;

    /**
     * Get a float value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    float getFloat(string name);
    alias getFloat = Tuple.getFloat;

    /**
     * Get a double value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    double getDouble(string name);
    alias getDouble = Tuple.getDouble;

    /**
     * Get a string value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    string getString(string name);
    alias getString = Tuple.getString;

    /**
     * Get a buffer value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    // Buffer getBuffer(string name);
    byte[] getBuffer(string name);
    alias getBuffer = Tuple.getBuffer;

    // /**
    //  * Get a temporal value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Temporal getTemporal(string name);

    // /**
    //  * Get {@link java.time.LocalDate} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDate getLocalDate(string name);

    // /**
    //  * Get {@link java.time.LocalTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalTime getLocalTime(string name);

    // /**
    //  * Get {@link java.time.LocalDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDateTime getLocalDateTime(string name);

    // /**
    //  * Get {@link java.time.OffsetTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetTime getOffsetTime(string name);

    // /**
    //  * Get {@link java.time.OffsetDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetDateTime getOffsetDateTime(string name);

    // /**
    //  * Get {@link java.util.UUID} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // UUID getUUID(string name);

    // /**
    //  * Get {@link BigDecimal} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // BigDecimal getBigDecimal(string name);

    // /**
    //  * Get an array of {@link Integer} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Integer[] getIntegerArray(string name);

    // /**
    //  * Get an array of {@link Boolean} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Boolean[] getBooleanArray(string name);

    // /**
    //  * Get an array of {@link Short} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Short[] getShortArray(string name);

    // /**
    //  * Get an array of {@link Long} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Long[] getLongArray(string name);

    // /**
    //  * Get an array of {@link Float} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Float[] getFloatArray(string name);

    // /**
    //  * Get an array of {@link Double} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Double[] getDoubleArray(string name);

    // /**
    //  * Get an array of {@link string} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // string[] getStringArray(string name);

    // /**
    //  * Get an array of {@link LocalDate} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDate[] getLocalDateArray(string name);

    // /**
    //  * Get an array of {@link LocalTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalTime[] getLocalTimeArray(string name);

    // /**
    //  * Get an array of {@link OffsetTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetTime[] getOffsetTimeArray(string name);

    // /**
    //  * Get an array of {@link LocalDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDateTime[] getLocalDateTimeArray(string name);

    // /**
    //  * Get an array of {@link OffsetDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetDateTime[] getOffsetDateTimeArray(string name);

    // /**
    //  * Get an array of {@link Buffer} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Buffer[] getBufferArray(string name);

    // /**
    //  * Get an array of {@link UUID} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // UUID[] getUUIDArray(string name);

    // <T> T[] getValues(Class!(T) type, int idx);

}
