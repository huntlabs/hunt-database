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

module hunt.database.postgresql.impl;

import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import hunt.database.postgresql.data.Box;
import hunt.database.postgresql.data.Circle;
import hunt.database.postgresql.data.Line;
import hunt.database.postgresql.data.LineSegment;
import hunt.database.base.data.Numeric;
import hunt.database.postgresql.data.Path;
import hunt.database.postgresql.data.Polygon;
import hunt.database.postgresql.data.Interval;
import hunt.database.postgresql.data.Point;
import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.RowInternal;
import io.vertx.core.buffer.Buffer;

import java.math.BigDecimal;
import java.time.*;
import java.time.temporal.Temporal;
import java.util.List;
import java.util.UUID;

class RowImpl : ArrayTuple implements RowInternal {

  // Linked list
  private RowInternal next;
  private final RowDesc desc;

  RowImpl(RowDesc desc) {
    super(desc.columnNames().size());
    this.desc = desc;
  }

  RowImpl(RowImpl row) {
    super(row);
    this.desc = row.desc;
  }

  override
  String getColumnName(int pos) {
    List!(String) columnNames = desc.columnNames();
    return pos < 0 || columnNames.size() - 1 < pos ? null : columnNames.get(pos);
  }

  override
  int getColumnIndex(String name) {
    if (name is null) {
      throw new NullPointerException();
    }
    return desc.columnNames().indexOf(name);
  }

  override
  <T> T get(Class!(T) type, int pos) {
    if (type == Boolean.class) {
      return type.cast(getBoolean(pos));
    } else if (type == Short.class) {
      return type.cast(getShort(pos));
    } else if (type == Integer.class) {
      return type.cast(getInteger(pos));
    } else if (type == Long.class) {
      return type.cast(getLong(pos));
    } else if (type == Float.class) {
      return type.cast(getFloat(pos));
    } else if (type == Double.class) {
      return type.cast(getDouble(pos));
    } else if (type == Character.class) {
      return type.cast(getChar(pos));
    } else if (type == Numeric.class) {
      return type.cast(getNumeric(pos));
    } else if (type == String.class) {
      return type.cast(getString(pos));
    } else if (type == Buffer.class) {
      return type.cast(getBuffer(pos));
    } else if (type == UUID.class) {
      return type.cast(getUUID(pos));
    } else if (type == LocalDate.class) {
      return type.cast(getLocalDate(pos));
    } else if (type == LocalTime.class) {
      return type.cast(getLocalTime(pos));
    } else if (type == OffsetTime.class) {
      return type.cast(getOffsetTime(pos));
    } else if (type == LocalDateTime.class) {
      return type.cast(getLocalDateTime(pos));
    } else if (type == OffsetDateTime.class) {
      return type.cast(getOffsetDateTime(pos));
    } else if (type == Interval.class) {
      return type.cast(getInterval(pos));
    } else if (type == Point.class) {
      return type.cast(getPoint(pos));
    } else if (type == Line.class) {
      return type.cast(getLine(pos));
    } else if (type == LineSegment.class) {
      return type.cast(getLineSegment(pos));
    } else if (type == Path.class) {
      return type.cast(getPath(pos));
    } else if (type == Polygon.class) {
      return type.cast(getPolygon(pos));
    } else if (type == Circle.class) {
      return type.cast(getCircle(pos));
    } else if (type == Box.class) {
      return type.cast(getBox(pos));
    } else if (type == JsonObject.class) {
      return type.cast(getJson(pos));
    } else if (type == JsonArray.class) {
      return type.cast(getJson(pos));
    } else if (type == Object.class) {
      return type.cast(get(pos));
    }
    throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
  }

  override
  <T> T[] getValues(Class!(T) type, int pos) {
    if (type == Boolean.class) {
      return (T[]) getBooleanArray(pos);
    } else if (type == Short.class) {
      return (T[]) getShortArray(pos);
    } else if (type == Integer.class) {
      return (T[]) getIntegerArray(pos);
    } else if (type == Long.class) {
      return (T[]) getLongArray(pos);
    } else if (type == Float.class) {
      return (T[]) getFloatArray(pos);
    } else if (type == Double.class) {
      return (T[]) getDoubleArray(pos);
    } else if (type == Character.class) {
      return (T[]) getCharArray(pos);
    } else if (type == String.class) {
      return (T[]) getStringArray(pos);
    } else if (type == Buffer.class) {
      return (T[]) getBufferArray(pos);
    } else if (type == UUID.class) {
      return (T[]) getUUIDArray(pos);
    } else if (type == LocalDate.class) {
      return (T[]) getLocalDateArray(pos);
    } else if (type == LocalTime.class) {
      return (T[]) getLocalTimeArray(pos);
    } else if (type == OffsetTime.class) {
      return (T[]) getOffsetTimeArray(pos);
    } else if (type == LocalDateTime.class) {
      return (T[]) getLocalDateTimeArray(pos);
    } else if (type == OffsetDateTime.class) {
      return (T[]) getOffsetDateTimeArray(pos);
    } else if (type == Interval.class) {
      return (T[]) getIntervalArray(pos);
    } else if (type == Numeric.class) {
      return (T[]) getNumericArray(pos);
    } else if (type == Point.class) {
      return (T[]) getPointArray(pos);
    } else if (type == Line.class) {
      return (T[]) getLineArray(pos);
    } else if (type == LineSegment.class) {
      return (T[]) getLineSegmentArray(pos);
    } else if (type == Path.class) {
      return (T[]) getPathArray(pos);
    } else if (type == Polygon.class) {
      return (T[]) getPolygonArray(pos);
    } else if (type == Circle.class) {
      return (T[]) getCircleArray(pos);
    } else if (type == Interval.class) {
      return (T[]) getIntervalArray(pos);
    } else if (type == Box.class) {
      return (T[]) getBoxArray(pos);
    } else if (type == Object.class) {
      return (T[]) getJsonArray(pos);
    }
    throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
  }

  override
  Boolean getBoolean(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBoolean(pos);
  }

  override
  Object getValue(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getValue(pos);
  }

  override
  Short getShort(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getShort(pos);
  }

  override
  Integer getInteger(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getInteger(pos);
  }

  override
  Long getLong(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLong(pos);
  }

  override
  Float getFloat(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getFloat(pos);
  }

  override
  Double getDouble(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getDouble(pos);
  }

  override
  String getString(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getString(pos);
  }

  override
  Buffer getBuffer(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBuffer(pos);
  }

  override
  Temporal getTemporal(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getTemporal(pos);
  }

  override
  LocalDate getLocalDate(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalDate(pos);
  }

  override
  LocalTime getLocalTime(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalTime(pos);
  }

  override
  LocalDateTime getLocalDateTime(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalDateTime(pos);
  }

  override
  OffsetTime getOffsetTime(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getOffsetTime(pos);
  }

  override
  OffsetDateTime getOffsetDateTime(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getOffsetDateTime(pos);
  }

  override
  UUID getUUID(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getUUID(pos);
  }

  override
  BigDecimal getBigDecimal(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBigDecimal(pos);
  }

  Numeric getNumeric(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getNumeric(pos);
  }

  Point getPoint(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPoint(pos);
  }

  Line getLine(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLine(pos);
  }

  LineSegment getLineSegment(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLineSegment(pos);
  }

  Box getBox(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBox(pos);
  }

  Path getPath(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPath(pos);
  }

  Polygon getPolygon(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPolygon(pos);
  }

  Circle getCircle(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getCircle(pos);
  }

  Interval getInterval(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getInterval(pos);
  }

  override
  Boolean[] getBooleanArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBooleanArray(pos);
  }

  override
  Short[] getShortArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getShortArray(pos);
  }

  override
  Integer[] getIntegerArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getIntegerArray(pos);
  }

  override
  Long[] getLongArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLongArray(pos);
  }

  override
  Float[] getFloatArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getFloatArray(pos);
  }

  override
  Double[] getDoubleArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getDoubleArray(pos);
  }

  override
  String[] getStringArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getStringArray(pos);
  }

  override
  LocalDate[] getLocalDateArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalDateArray(pos);
  }

  override
  LocalTime[] getLocalTimeArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalTimeArray(pos);
  }

  override
  OffsetTime[] getOffsetTimeArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getOffsetTimeArray(pos);
  }

  override
  LocalDateTime[] getLocalDateTimeArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLocalDateTimeArray(pos);
  }

  override
  OffsetDateTime[] getOffsetDateTimeArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getOffsetDateTimeArray(pos);
  }

  override
  Buffer[] getBufferArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBufferArray(pos);
  }

  override
  UUID[] getUUIDArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getUUIDArray(pos);
  }

  Object[] getJsonArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getJsonArray(pos);
  }

  Numeric[] getNumericArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getNumericArray(pos);
  }

  Point[] getPointArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPointArray(pos);
  }

  Line[] getLineArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLineArray(pos);
  }

  LineSegment[] getLineSegmentArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getLineSegmentArray(pos);
  }

  Box[] getBoxArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getBoxArray(pos);
  }

  Path[] getPathArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPathArray(pos);
  }

  Polygon[] getPolygonArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getPolygonArray(pos);
  }

  Circle[] getCircleArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getCircleArray(pos);
  }

  Interval[] getIntervalArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getIntervalArray(pos);
  }

  Character[] getCharArray(String name) {
    int pos = desc.columnIndex(name);
    return pos == -1 ? null : getCharArray(pos);
  }

  Character getChar(int pos) {
    Object val = get(pos);
    if (val instanceof Character) {
      return (Character) val;
    } else {
      return null;
    }
  }

  Numeric getNumeric(int pos) {
    Object val = get(pos);
    if (val instanceof Numeric) {
      return (Numeric) val;
    } else if (val instanceof Number) {
      return Numeric.parse(val.toString());
    }
    return null;
  }

  /**
   * Get a {@link io.vertx.core.json.JsonObject} or {@link io.vertx.core.json.JsonArray} value.
   */
  Object getJson(int pos) {
    Object val = get(pos);
    if (val instanceof JsonObject) {
      return val;
    } else if (val instanceof JsonArray) {
      return val;
    } else {
      return null;
    }
  }

  Point getPoint(int pos) {
    Object val = get(pos);
    if (val instanceof Point) {
      return (Point) val;
    } else {
      return null;
    }
  }

  Line getLine(int pos) {
    Object val = get(pos);
    if (val instanceof Line) {
      return (Line) val;
    } else {
      return null;
    }
  }

  LineSegment getLineSegment(int pos) {
    Object val = get(pos);
    if (val instanceof LineSegment) {
      return (LineSegment) val;
    } else {
      return null;
    }
  }

  Box getBox(int pos) {
    Object val = get(pos);
    if (val instanceof Box) {
      return (Box) val;
    } else {
      return null;
    }
  }

  Path getPath(int pos) {
    Object val = get(pos);
    if (val instanceof Path) {
      return (Path) val;
    } else {
      return null;
    }
  }

  Polygon getPolygon(int pos) {
    Object val = get(pos);
    if (val instanceof Polygon) {
      return (Polygon) val;
    } else {
      return null;
    }
  }

  Circle getCircle(int pos) {
    Object val = get(pos);
    if (val instanceof Circle) {
      return (Circle) val;
    } else {
      return null;
    }
  }

  Interval getInterval(int pos) {
    Object val = get(pos);
    if (val instanceof Interval) {
      return (Interval) val;
    } else {
      return null;
    }
  }

  Character[] getCharArray(int pos) {
    Object val = get(pos);
    if (val instanceof Character[]) {
      return (Character[]) val;
    } else {
      return null;
    }
  }

  /**
   * Get a {@code Json} array value, the {@code Json} value may be a string, number, JSON object, array, boolean or null.
   */
  Object[] getJsonArray(int pos) {
    Object val = get(pos);
    if (val instanceof Object[]) {
      return (Object[]) val;
    } else {
      return null;
    }
  }

  Numeric[] getNumericArray(int pos) {
    Object val = get(pos);
    if (val instanceof Numeric[]) {
      return (Numeric[]) val;
    } else {
      return null;
    }
  }

  Point[] getPointArray(int pos) {
    Object val = get(pos);
    if (val instanceof Point[]) {
      return (Point[]) val;
    } else {
      return null;
    }
  }

  Line[] getLineArray(int pos) {
    Object val = get(pos);
    if (val instanceof Line[]) {
      return (Line[]) val;
    } else {
      return null;
    }
  }

  LineSegment[] getLineSegmentArray(int pos) {
    Object val = get(pos);
    if (val instanceof LineSegment[]) {
      return (LineSegment[]) val;
    } else {
      return null;
    }
  }

  Box[] getBoxArray(int pos) {
    Object val = get(pos);
    if (val instanceof Box[]) {
      return (Box[]) val;
    } else {
      return null;
    }
  }

  Path[] getPathArray(int pos) {
    Object val = get(pos);
    if (val instanceof Path[]) {
      return (Path[]) val;
    } else {
      return null;
    }
  }

  Polygon[] getPolygonArray(int pos) {
    Object val = get(pos);
    if (val instanceof Polygon[]) {
      return (Polygon[]) val;
    } else {
      return null;
    }
  }

  Circle[] getCircleArray(int pos) {
    Object val = get(pos);
    if (val instanceof Circle[]) {
      return (Circle[]) val;
    } else {
      return null;
    }
  }

  Interval[] getIntervalArray(int pos) {
    Object val = get(pos);
    if (val instanceof Interval[]) {
      return (Interval[]) val;
    } else {
      return null;
    }
  }

  override
  void setNext(RowInternal next) {
    this.next = next;
  }

  override
  RowInternal getNext() {
    return next;
  }
}
