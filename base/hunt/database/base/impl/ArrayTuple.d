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

module hunt.database.base.impl.ArrayTuple;

import hunt.database.base.Tuple;
// import io.vertx.core.buffer.Buffer;

// import java.math.BigDecimal;
// import java.time.*;
// import java.time.temporal.Temporal;
// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.UUID;

import hunt.collection.ArrayList;
import hunt.collection.Collection;

import std.concurrency : initOnce;

/**
*/
class ArrayTuple : ArrayList!(Object), Tuple {

    static Tuple EMPTY() {
        __gshared Tuple inst;
        return initOnce!inst(new ArrayTuple(0));
    }

    this(int len) {
        super(len);
    }

    this(Collection!(Object) c) {
        super(c);
    }

    // override
    // <T> T get(Class!(T) type, int pos) {
    //     throw new UnsupportedOperationException();
    // }

    // override
    // <T> T[] getValues(Class!(T) type, int pos) {
    //     throw new UnsupportedOperationException();
    // }

    // override
    // Boolean getBoolean(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Boolean) {
    //         return (Boolean) val;
    //     }
    //     return null;
    // }

    // override
    // Object getValue(int pos) {
    //     return get(pos);
    // }

    // override
    // Short getShort(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Short) {
    //         return (Short) val;
    //     } else if (val instanceof Number) {
    //         return ((Number) val).shortValue();
    //     }
    //     return null;
    // }

    // override
    // Integer getInteger(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Integer) {
    //         return (Integer) val;
    //     } else if (val instanceof Number) {
    //         return ((Number) val).intValue();
    //     }
    //     return null;
    // }

    // override
    // Long getLong(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Long) {
    //         return (Long) val;
    //     } else if (val instanceof Number) {
    //         return ((Number) val).longValue();
    //     }
    //     return null;
    // }

    // override
    // Float getFloat(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Float) {
    //         return (Float) val;
    //     } else if (val instanceof Number) {
    //         return ((Number) val).floatValue();
    //     }
    //     return null;
    // }

    // override
    // Double getDouble(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Double) {
    //         return (Double) val;
    //     } else if (val instanceof Number) {
    //         return ((Number) val).doubleValue();
    //     }
    //     return null;
    // }

    // override
    // BigDecimal getBigDecimal(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof BigDecimal) {
    //         return (BigDecimal) val;
    //     } else if (val instanceof Number) {
    //         return new BigDecimal(val.toString());
    //     }
    //     return null;
    // }

    // override
    // Integer[] getIntegerArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Integer[]) {
    //         return (Integer[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Boolean[] getBooleanArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Boolean[]) {
    //         return (Boolean[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Short[] getShortArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Short[]) {
    //         return (Short[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Long[] getLongArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Long[]) {
    //         return (Long[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Float[] getFloatArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Float[]) {
    //         return (Float[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Double[] getDoubleArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Double[]) {
    //         return (Double[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // String[] getStringArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof String[]) {
    //         return (String[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // LocalDate[] getLocalDateArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalDate[]) {
    //         return (LocalDate[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // LocalTime[] getLocalTimeArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalTime[]) {
    //         return (LocalTime[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // OffsetTime[] getOffsetTimeArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof OffsetTime[]) {
    //         return (OffsetTime[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // LocalDateTime[] getLocalDateTimeArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalDateTime[]) {
    //         return (LocalDateTime[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // OffsetDateTime[] getOffsetDateTimeArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof OffsetDateTime[]) {
    //         return (OffsetDateTime[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // Buffer[] getBufferArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Buffer[]) {
    //         return (Buffer[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // UUID[] getUUIDArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof UUID[]) {
    //         return (UUID[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // override
    // String getString(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof String) {
    //         return (String) val;
    //     }
    //     return null;
    // }

    // override
    // Buffer getBuffer(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Buffer) {
    //         return (Buffer) val;
    //     }
    //     return null;
    // }

    // override
    // Temporal getTemporal(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Temporal) {
    //         return (Temporal) val;
    //     }
    //     return null;
    // }

    // override
    // LocalDate getLocalDate(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalDate) {
    //         return (LocalDate) val;
    //     }
    //     return null;
    // }

    // override
    // LocalTime getLocalTime(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalTime) {
    //         return (LocalTime) val;
    //     }
    //     return null;
    // }

    // override
    // LocalDateTime getLocalDateTime(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LocalDateTime) {
    //         return (LocalDateTime) val;
    //     }
    //     return null;
    // }

    // override
    // OffsetTime getOffsetTime(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof OffsetTime) {
    //         return (OffsetTime) val;
    //     }
    //     return null;
    // }

    // override
    // OffsetDateTime getOffsetDateTime(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof OffsetDateTime) {
    //         return (OffsetDateTime) val;
    //     }
    //     return null;
    // }

    // override
    // UUID getUUID(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof UUID) {
    //         return (UUID) val;
    //     }
    //     return null;
    // }

    // override
    // Tuple addBoolean(Boolean value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addValue(Object value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addShort(Short value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addInteger(Integer value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLong(Long value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addFloat(Float value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addDouble(Double value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addString(String value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addBuffer(Buffer value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addTemporal(Temporal value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalDate(LocalDate value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalTime(LocalTime value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalDateTime(LocalDateTime value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addOffsetTime(OffsetTime value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addOffsetDateTime(OffsetDateTime value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addUUID(UUID value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addBigDecimal(BigDecimal value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addIntegerArray(Integer[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addBooleanArray(Boolean[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addShortArray(Short[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLongArray(Long[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addFloatArray(Float[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addDoubleArray(Double[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addStringArray(String[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalDateArray(LocalDate[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalTimeArray(LocalTime[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addOffsetTimeArray(OffsetTime[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addLocalDateTimeArray(LocalDateTime[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addOffsetDateTimeArray(OffsetDateTime[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addBufferArray(Buffer[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // Tuple addUUIDArray(UUID[] value) {
    //     add(value);
    //     return this;
    // }

    // override
    // <T> Tuple addValues(T[] value) {
    //     add(value);
    //     return this;
    // }
}
