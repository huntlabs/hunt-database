module hunt.database.mysql.impl.MySQLRowImpl;

import hunt.database.base.data.Numeric;
import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.RowImpl;
import hunt.database.base.impl.RowInternal;

// import java.math.BigDecimal;
// import java.time.Duration;
// import java.time.LocalDate;
// import java.time.LocalDateTime;
// import java.time.LocalTime;
// import java.time.OffsetDateTime;
// import java.time.OffsetTime;
// import java.time.temporal.Temporal;

import hunt.collection.List;
import hunt.Exceptions;
import hunt.math.BigDecimal;

import std.algorithm;
import std.string;
import std.variant;


class MySQLRowImpl : RowImpl {

	// MySQLRowImpl next;

	this(RowDesc desc) {
        super(desc);
	}

	// override
	// <T> T get(Class!(T) type, int pos) {
	// 	if (type == Boolean.class) {
	// 		return type.cast(getBoolean(pos));
	// 	} else if (type == Byte.class) {
	// 		return type.cast(getByte(pos));
	// 	} else if (type == Short.class) {
	// 		return type.cast(getShort(pos));
	// 	} else if (type == Integer.class) {
	// 		return type.cast(getInteger(pos));
	// 	} else if (type == Long.class) {
	// 		return type.cast(getLong(pos));
	// 	} else if (type == Float.class) {
	// 		return type.cast(getFloat(pos));
	// 	} else if (type == Double.class) {
	// 		return type.cast(getDouble(pos));
	// 	} else if (type == Numeric.class) {
	// 		return type.cast(getNumeric(pos));
	// 	} else if (type == string.class) {
	// 		return type.cast(getString(pos));
	// 	} else if (type == Buffer.class) {
	// 		return type.cast(getBuffer(pos));
	// 	} else if (type == LocalDate.class) {
	// 		return type.cast(getLocalDate(pos));
	// 	} else if (type == LocalDateTime.class) {
	// 		return type.cast(getLocalDateTime(pos));
	// 	} else if (type == Duration.class) {
	// 		return type.cast(getDuration(pos));
	// 	} else {
	// 		throw new UnsupportedOperationException("Unsupported type " ~ type.getName());
	// 	}
	// }

	// override
	// <T> T[] getValues(Class!(T) type, int idx) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Object getValue(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getValue(pos);
	// }

	// override
	// Boolean getBoolean(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getBoolean(pos);
	// }

	// override
	// Short getShort(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getShort(pos);
	// }

	// override
	// Integer getInteger(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getInteger(pos);
	// }

	// override
	// Long getLong(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getLong(pos);
	// }

	// override
	// Float getFloat(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getFloat(pos);
	// }

	// override
	// Double getDouble(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getDouble(pos);
	// }

	// Numeric getNumeric(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getNumeric(pos);
	// }

	// override
	// string getString(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getString(pos);
	// }

	// override
	// Buffer getBuffer(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getBuffer(pos);
	// }

	// override
	// Temporal getTemporal(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// LocalDate getLocalDate(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getLocalDate(pos);
	// }

	// override
	// LocalTime getLocalTime(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// LocalDateTime getLocalDateTime(string name) {
	// 	int pos = rowDesc.columnIndex(name);
	// 	return pos == -1 ? null : getLocalDateTime(pos);
	// }

	// override
	// OffsetTime getOffsetTime(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// OffsetDateTime getOffsetDateTime(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// UUID getUUID(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// BigDecimal getBigDecimal(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Integer[] getIntegerArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Boolean[] getBooleanArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Short[] getShortArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Long[] getLongArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Float[] getFloatArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Double[] getDoubleArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// string[] getStringArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// LocalDate[] getLocalDateArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// LocalTime[] getLocalTimeArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// OffsetTime[] getOffsetTimeArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// LocalDateTime[] getLocalDateTimeArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// OffsetDateTime[] getOffsetDateTimeArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// Buffer[] getBufferArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }

	// override
	// UUID[] getUUIDArray(string name) {
	// 	throw new UnsupportedOperationException();
	// }


	// override
	// Boolean getBoolean(int pos) {
	// 	// in MySQL BOOLEAN type is mapped to TINYINT
	// 	Object val = get(pos);
	// 	if (val instanceof Boolean) {
	// 		return (Boolean) val;
	// 	} else if (val instanceof Byte) {
	// 		return (Byte) val != 0;
	// 	}
	// 	return null;
	// }

	// Numeric getNumeric(int pos) {
	// 	Object val = get(pos);
	// 	if (val instanceof Numeric) {
	// 		return (Numeric) val;
	// 	} else if (val instanceof Number) {
	// 		return Numeric.parse(val.toString());
	// 	}
	// 	return null;
	// }

	// private Byte getByte(int pos) {
	// 	Object val = get(pos);
	// 	if (val instanceof Byte) {
	// 		return (Byte) val;
	// 	} else if (val instanceof Number) {
	// 		return ((Number) val).byteValue();
	// 	}
	// 	return null;
	// }

	// private Duration getDuration(int pos) {
	// 	Object val = get(pos);
	// 	if (val instanceof Duration) {
	// 		return (Duration) val;
	// 	}
	// 	return null;
	// }
}
