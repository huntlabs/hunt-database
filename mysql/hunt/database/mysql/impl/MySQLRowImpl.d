module hunt.database.mysql.impl.MySQLRowImpl;

import hunt.database.base.data.Numeric;
import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.RowInternal;
import hunt.database.base.impl.RowDesc;
import io.vertx.core.buffer.Buffer;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.OffsetTime;
import java.time.temporal.Temporal;
import hunt.collection.List;
import java.util.UUID;

class MySQLRowImpl : ArrayTuple implements RowInternal {

  private final RowDesc rowDesc;
  MySQLRowImpl next;

  MySQLRowImpl(RowDesc rowDesc) {
    super(rowDesc.columnNames().size());
    this.rowDesc = rowDesc;
  }

  override
  <T> T get(Class!(T) type, int pos) {
    if (type == Boolean.class) {
      return type.cast(getBoolean(pos));
    } else if (type == Byte.class) {
      return type.cast(getByte(pos));
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
    } else if (type == Numeric.class) {
      return type.cast(getNumeric(pos));
    } else if (type == String.class) {
      return type.cast(getString(pos));
    } else if (type == Buffer.class) {
      return type.cast(getBuffer(pos));
    } else if (type == LocalDate.class) {
      return type.cast(getLocalDate(pos));
    } else if (type == LocalDateTime.class) {
      return type.cast(getLocalDateTime(pos));
    } else if (type == Duration.class) {
      return type.cast(getDuration(pos));
    } else {
      throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
    }
  }

  override
  <T> T[] getValues(Class!(T) type, int idx) {
    throw new UnsupportedOperationException();
  }

  override
  String getColumnName(int pos) {
    List!(String) columnNames = rowDesc.columnNames();
    return pos < 0 || columnNames.size() - 1 < pos ? null : columnNames.get(pos);
  }

  override
  int getColumnIndex(String name) {
    if (name is null) {
      throw new NullPointerException();
    }
    return rowDesc.columnNames().indexOf(name);
  }

  override
  Object getValue(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getValue(pos);
  }

  override
  Boolean getBoolean(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getBoolean(pos);
  }

  override
  Short getShort(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getShort(pos);
  }

  override
  Integer getInteger(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getInteger(pos);
  }

  override
  Long getLong(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getLong(pos);
  }

  override
  Float getFloat(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getFloat(pos);
  }

  override
  Double getDouble(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getDouble(pos);
  }

  Numeric getNumeric(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getNumeric(pos);
  }

  override
  String getString(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getString(pos);
  }

  override
  Buffer getBuffer(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getBuffer(pos);
  }

  override
  Temporal getTemporal(String name) {
    throw new UnsupportedOperationException();
  }

  override
  LocalDate getLocalDate(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getLocalDate(pos);
  }

  override
  LocalTime getLocalTime(String name) {
    throw new UnsupportedOperationException();
  }

  override
  LocalDateTime getLocalDateTime(String name) {
    int pos = rowDesc.columnIndex(name);
    return pos == -1 ? null : getLocalDateTime(pos);
  }

  override
  OffsetTime getOffsetTime(String name) {
    throw new UnsupportedOperationException();
  }

  override
  OffsetDateTime getOffsetDateTime(String name) {
    throw new UnsupportedOperationException();
  }

  override
  UUID getUUID(String name) {
    throw new UnsupportedOperationException();
  }

  override
  BigDecimal getBigDecimal(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Integer[] getIntegerArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Boolean[] getBooleanArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Short[] getShortArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Long[] getLongArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Float[] getFloatArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Double[] getDoubleArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  String[] getStringArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  LocalDate[] getLocalDateArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  LocalTime[] getLocalTimeArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  OffsetTime[] getOffsetTimeArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  LocalDateTime[] getLocalDateTimeArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  OffsetDateTime[] getOffsetDateTimeArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  Buffer[] getBufferArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  UUID[] getUUIDArray(String name) {
    throw new UnsupportedOperationException();
  }

  override
  RowInternal getNext() {
    return next;
  }

  override
  void setNext(RowInternal next) {
    this.next = (MySQLRowImpl) next;
  }

  override
  Boolean getBoolean(int pos) {
    // in MySQL BOOLEAN type is mapped to TINYINT
    Object val = get(pos);
    if (val instanceof Boolean) {
      return (Boolean) val;
    } else if (val instanceof Byte) {
      return (Byte) val != 0;
    }
    return null;
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

  private Byte getByte(int pos) {
    Object val = get(pos);
    if (val instanceof Byte) {
      return (Byte) val;
    } else if (val instanceof Number) {
      return ((Number) val).byteValue();
    }
    return null;
  }

  private Duration getDuration(int pos) {
    Object val = get(pos);
    if (val instanceof Duration) {
      return (Duration) val;
    }
    return null;
  }
}
