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

module hunt.database.postgresql.impl.RowImpl;


import hunt.database.postgresql.data.Box;
import hunt.database.postgresql.data.Circle;
import hunt.database.postgresql.data.Line;
import hunt.database.postgresql.data.LineSegment;
import hunt.database.postgresql.data.Path;
import hunt.database.postgresql.data.Polygon;
import hunt.database.postgresql.data.Interval;
import hunt.database.postgresql.data.Point;
import hunt.database.base.data.Numeric;
import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.RowInternal;
// import io.vertx.core.buffer.Buffer;

import hunt.collection.List;
import hunt.Exceptions;
import hunt.math.BigDecimal;

import std.algorithm;
import std.string;
import std.variant;


class RowImpl : ArrayTuple, RowInternal {

    // Linked list
    private RowInternal next;
    private RowDesc desc;

    this(RowDesc desc) {
        super(cast(int)desc.columnNames().length);
        this.desc = desc;
    }

    this(RowImpl row) {
        super(row);
        this.desc = row.desc;
    }

    override
    string getColumnName(int pos) {
        string[] columnNames = desc.columnNames();
        return pos < 0 || columnNames.length - 1 < pos ? null : columnNames[pos];
    }

    override
    int getColumnIndex(string name) {
        if (name.empty()) {
            throw new NullPointerException();
        }
        return cast(int)desc.columnNames().countUntil(name);
    }

    // override
    // <T> T get(Class!(T) type, int pos) {
    //     if (type == Boolean.class) {
    //         return type.cast(getBoolean(pos));
    //     } else if (type == Short.class) {
    //         return type.cast(getShort(pos));
    //     } else if (type == Integer.class) {
    //         return type.cast(getInteger(pos));
    //     } else if (type == Long.class) {
    //         return type.cast(getLong(pos));
    //     } else if (type == Float.class) {
    //         return type.cast(getFloat(pos));
    //     } else if (type == Double.class) {
    //         return type.cast(getDouble(pos));
    //     } else if (type == Character.class) {
    //         return type.cast(getChar(pos));
    //     } else if (type == Numeric.class) {
    //         return type.cast(getNumeric(pos));
    //     } else if (type == string.class) {
    //         return type.cast(getString(pos));
    //     } else if (type == Buffer.class) {
    //         return type.cast(getBuffer(pos));
    //     } else if (type == UUID.class) {
    //         return type.cast(getUUID(pos));
    //     } else if (type == LocalDate.class) {
    //         return type.cast(getLocalDate(pos));
    //     } else if (type == LocalTime.class) {
    //         return type.cast(getLocalTime(pos));
    //     } else if (type == OffsetTime.class) {
    //         return type.cast(getOffsetTime(pos));
    //     } else if (type == LocalDateTime.class) {
    //         return type.cast(getLocalDateTime(pos));
    //     } else if (type == OffsetDateTime.class) {
    //         return type.cast(getOffsetDateTime(pos));
    //     } else if (type == Interval.class) {
    //         return type.cast(getInterval(pos));
    //     } else if (type == Point.class) {
    //         return type.cast(getPoint(pos));
    //     } else if (type == Line.class) {
    //         return type.cast(getLine(pos));
    //     } else if (type == LineSegment.class) {
    //         return type.cast(getLineSegment(pos));
    //     } else if (type == Path.class) {
    //         return type.cast(getPath(pos));
    //     } else if (type == Polygon.class) {
    //         return type.cast(getPolygon(pos));
    //     } else if (type == Circle.class) {
    //         return type.cast(getCircle(pos));
    //     } else if (type == Box.class) {
    //         return type.cast(getBox(pos));
    //     } else if (type == JsonObject.class) {
    //         return type.cast(getJson(pos));
    //     } else if (type == JsonArray.class) {
    //         return type.cast(getJson(pos));
    //     } else if (type == Object.class) {
    //         return type.cast(get(pos));
    //     }
    //     throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
    // }

    // override
    // <T> T[] getValues(Class!(T) type, int pos) {
    //     if (type == Boolean.class) {
    //         return (T[]) getBooleanArray(pos);
    //     } else if (type == Short.class) {
    //         return (T[]) getShortArray(pos);
    //     } else if (type == Integer.class) {
    //         return (T[]) getIntegerArray(pos);
    //     } else if (type == Long.class) {
    //         return (T[]) getLongArray(pos);
    //     } else if (type == Float.class) {
    //         return (T[]) getFloatArray(pos);
    //     } else if (type == Double.class) {
    //         return (T[]) getDoubleArray(pos);
    //     } else if (type == Character.class) {
    //         return (T[]) getCharArray(pos);
    //     } else if (type == string.class) {
    //         return (T[]) getStringArray(pos);
    //     } else if (type == Buffer.class) {
    //         return (T[]) getBufferArray(pos);
    //     } else if (type == UUID.class) {
    //         return (T[]) getUUIDArray(pos);
    //     } else if (type == LocalDate.class) {
    //         return (T[]) getLocalDateArray(pos);
    //     } else if (type == LocalTime.class) {
    //         return (T[]) getLocalTimeArray(pos);
    //     } else if (type == OffsetTime.class) {
    //         return (T[]) getOffsetTimeArray(pos);
    //     } else if (type == LocalDateTime.class) {
    //         return (T[]) getLocalDateTimeArray(pos);
    //     } else if (type == OffsetDateTime.class) {
    //         return (T[]) getOffsetDateTimeArray(pos);
    //     } else if (type == Interval.class) {
    //         return (T[]) getIntervalArray(pos);
    //     } else if (type == Numeric.class) {
    //         return (T[]) getNumericArray(pos);
    //     } else if (type == Point.class) {
    //         return (T[]) getPointArray(pos);
    //     } else if (type == Line.class) {
    //         return (T[]) getLineArray(pos);
    //     } else if (type == LineSegment.class) {
    //         return (T[]) getLineSegmentArray(pos);
    //     } else if (type == Path.class) {
    //         return (T[]) getPathArray(pos);
    //     } else if (type == Polygon.class) {
    //         return (T[]) getPolygonArray(pos);
    //     } else if (type == Circle.class) {
    //         return (T[]) getCircleArray(pos);
    //     } else if (type == Interval.class) {
    //         return (T[]) getIntervalArray(pos);
    //     } else if (type == Box.class) {
    //         return (T[]) getBoxArray(pos);
    //     } else if (type == Object.class) {
    //         return (T[]) getJsonArray(pos);
    //     }
    //     throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
    // }

    // override
    // Boolean getBoolean(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBoolean(pos);
    // }

    // override
    Variant getValue(string name) {
        int pos = desc.columnIndex(name);
        return pos == -1 ? Variant() : getValue(pos);
    }

    alias getValue = ArrayTuple.getValue;

    // override
    // Short getShort(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getShort(pos);
    // }

    // override
    // Integer getInteger(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getInteger(pos);
    // }

    // override
    // Long getLong(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLong(pos);
    // }

    // override
    // Float getFloat(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getFloat(pos);
    // }

    // override
    // Double getDouble(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getDouble(pos);
    // }

    // override
    // string getString(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getString(pos);
    // }

    // override
    // Buffer getBuffer(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBuffer(pos);
    // }

    // override
    // Temporal getTemporal(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getTemporal(pos);
    // }

    // override
    // LocalDate getLocalDate(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalDate(pos);
    // }

    // override
    // LocalTime getLocalTime(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalTime(pos);
    // }

    // override
    // LocalDateTime getLocalDateTime(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalDateTime(pos);
    // }

    // override
    // OffsetTime getOffsetTime(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getOffsetTime(pos);
    // }

    // override
    // OffsetDateTime getOffsetDateTime(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getOffsetDateTime(pos);
    // }

    // override
    // UUID getUUID(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getUUID(pos);
    // }

    // override
    // BigDecimal getBigDecimal(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBigDecimal(pos);
    // }

    // Numeric getNumeric(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getNumeric(pos);
    // }

    // Point getPoint(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPoint(pos);
    // }

    // Line getLine(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLine(pos);
    // }

    // LineSegment getLineSegment(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLineSegment(pos);
    // }

    // Box getBox(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBox(pos);
    // }

    // Path getPath(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPath(pos);
    // }

    // Polygon getPolygon(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPolygon(pos);
    // }

    // Circle getCircle(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getCircle(pos);
    // }

    // Interval getInterval(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getInterval(pos);
    // }

    // override
    // Boolean[] getBooleanArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBooleanArray(pos);
    // }

    // override
    // Short[] getShortArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getShortArray(pos);
    // }

    // override
    // Integer[] getIntegerArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getIntegerArray(pos);
    // }

    // override
    // Long[] getLongArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLongArray(pos);
    // }

    // override
    // Float[] getFloatArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getFloatArray(pos);
    // }

    // override
    // Double[] getDoubleArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getDoubleArray(pos);
    // }

    // override
    // string[] getStringArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getStringArray(pos);
    // }

    // override
    // LocalDate[] getLocalDateArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalDateArray(pos);
    // }

    // override
    // LocalTime[] getLocalTimeArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalTimeArray(pos);
    // }

    // override
    // OffsetTime[] getOffsetTimeArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getOffsetTimeArray(pos);
    // }

    // override
    // LocalDateTime[] getLocalDateTimeArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLocalDateTimeArray(pos);
    // }

    // override
    // OffsetDateTime[] getOffsetDateTimeArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getOffsetDateTimeArray(pos);
    // }

    // override
    // Buffer[] getBufferArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBufferArray(pos);
    // }

    // override
    // UUID[] getUUIDArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getUUIDArray(pos);
    // }

    // Object[] getJsonArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getJsonArray(pos);
    // }

    // Numeric[] getNumericArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getNumericArray(pos);
    // }

    // Point[] getPointArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPointArray(pos);
    // }

    // Line[] getLineArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLineArray(pos);
    // }

    // LineSegment[] getLineSegmentArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getLineSegmentArray(pos);
    // }

    // Box[] getBoxArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getBoxArray(pos);
    // }

    // Path[] getPathArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPathArray(pos);
    // }

    // Polygon[] getPolygonArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getPolygonArray(pos);
    // }

    // Circle[] getCircleArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getCircleArray(pos);
    // }

    // Interval[] getIntervalArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getIntervalArray(pos);
    // }

    // Character[] getCharArray(string name) {
    //     int pos = desc.columnIndex(name);
    //     return pos == -1 ? null : getCharArray(pos);
    // }

    // Character getChar(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Character) {
    //         return (Character) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Numeric getNumeric(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Numeric) {
    //         return (Numeric) val;
    //     } else if (val instanceof Number) {
    //         return Numeric.parse(val.toString());
    //     }
    //     return null;
    // }

    // /**
    //  * Get a {@link io.vertx.core.json.JsonObject} or {@link io.vertx.core.json.JsonArray} value.
    //  */
    // Object getJson(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof JsonObject) {
    //         return val;
    //     } else if (val instanceof JsonArray) {
    //         return val;
    //     } else {
    //         return null;
    //     }
    // }

    // Point getPoint(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Point) {
    //         return (Point) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Line getLine(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Line) {
    //         return (Line) val;
    //     } else {
    //         return null;
    //     }
    // }

    // LineSegment getLineSegment(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LineSegment) {
    //         return (LineSegment) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Box getBox(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Box) {
    //         return (Box) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Path getPath(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Path) {
    //         return (Path) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Polygon getPolygon(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Polygon) {
    //         return (Polygon) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Circle getCircle(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Circle) {
    //         return (Circle) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Interval getInterval(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Interval) {
    //         return (Interval) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Character[] getCharArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Character[]) {
    //         return (Character[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // /**
    //  * Get a {@code Json} array value, the {@code Json} value may be a string, number, JSON object, array, boolean or null.
    //  */
    // Object[] getJsonArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Object[]) {
    //         return (Object[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Numeric[] getNumericArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Numeric[]) {
    //         return (Numeric[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Point[] getPointArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Point[]) {
    //         return (Point[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Line[] getLineArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Line[]) {
    //         return (Line[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // LineSegment[] getLineSegmentArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof LineSegment[]) {
    //         return (LineSegment[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Box[] getBoxArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Box[]) {
    //         return (Box[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Path[] getPathArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Path[]) {
    //         return (Path[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Polygon[] getPolygonArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Polygon[]) {
    //         return (Polygon[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Circle[] getCircleArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Circle[]) {
    //         return (Circle[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    // Interval[] getIntervalArray(int pos) {
    //     Object val = get(pos);
    //     if (val instanceof Interval[]) {
    //         return (Interval[]) val;
    //     } else {
    //         return null;
    //     }
    // }

    override
    void setNext(RowInternal next) {
        this.next = next;
    }

    override
    RowInternal getNext() {
        return next;
    }
}
