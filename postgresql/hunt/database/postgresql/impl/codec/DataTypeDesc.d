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
module hunt.database.postgresql.impl.codec.DataTypeDesc;

import hunt.database.postgresql.impl.codec.DataType;

import hunt.database.postgresql.data.Box;
import hunt.database.postgresql.data.Circle;
import hunt.database.postgresql.data.Line;
import hunt.database.postgresql.data.LineSegment;
import hunt.database.postgresql.data.Interval;
import hunt.database.postgresql.data.Path;
import hunt.database.postgresql.data.Point;
import hunt.database.postgresql.data.Polygon;

import hunt.database.base.data.Numeric;

import hunt.util.ObjectUtils;

import std.format;
import std.conv;

/**
 * PostgreSQL <a href="https://github.com/postgres/postgres/blob/master/src/include/catalog/pg_type.h">object
 * identifiers (OIDs)</a> for data types
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
struct DataTypeDesc {

    int id;
    bool supportsBinary;
    TypeInfo encodingType; // Not really used for now
    TypeInfo decodingType;

    this(int id, bool supportsBinary, TypeInfo_Class type) {
        this.id = id;
        this.supportsBinary = supportsBinary;
        this.decodingType = type;
        this.encodingType = type;
    }

    this(int id, bool supportsBinary, TypeInfo_Class encodingType, TypeInfo_Class decodingType) {
        this.id = id;
        this.supportsBinary = supportsBinary;
        this.encodingType = encodingType;
        this.decodingType = decodingType;
    }

    string toString() {
        return format("DataType=%s(%d), supportsBinary=%s", cast(DataType)id, id, supportsBinary);
    }

    // static DataType valueOf(int oid) {
    //     DataType value = oidToDataType.get(oid);
    //     if (value is null) {
    //         logger.debug("Postgres type OID=" ~ oid ~ " not handled - using unknown type instead");
    //         return UNKNOWN;
    //     } else {
    //         return value;
    //     }
    // }

    // private static IntObjectMap!(DataType) oidToDataType = new IntObjectHashMap<>();

    // static {
    //     for (DataType dataType : values()) {
    //         oidToDataType.put(dataType.id, dataType);
    //     }
    // }
}


    
struct DataTypes {

    enum DataTypeDesc BOOL = DataTypeDesc(16, true, null); // Boolean.class);
    enum DataTypeDesc BOOL_ARRAY = DataTypeDesc(1000, true, null); // Boolean[].class);
    enum DataTypeDesc INT2 = DataTypeDesc(21, true, null); // Short.class, Number.class);
    enum DataTypeDesc INT2_ARRAY = DataTypeDesc(1005, true, null); // Short[].class, Number[].class);
    enum DataTypeDesc INT4 = DataTypeDesc(23, true, null); // Integer.class, Number.class);
    enum DataTypeDesc INT4_ARRAY = DataTypeDesc(1007, true, null); // Integer[].class, Number[].class);
    enum DataTypeDesc INT8 = DataTypeDesc(20, true, null); // Long.class, Number.class);
    enum DataTypeDesc INT8_ARRAY = DataTypeDesc(1016, true, null); // Long[].class, Number[].class);
    enum DataTypeDesc FLOAT4 = DataTypeDesc(700, true, null); // Float.class, Number.class);
    enum DataTypeDesc FLOAT4_ARRAY = DataTypeDesc(1021, true, null); // Float[].class, Number[].class);
    enum DataTypeDesc FLOAT8 = DataTypeDesc(701, true, null); // Double.class, Number.class);
    enum DataTypeDesc FLOAT8_ARRAY = DataTypeDesc(1022, true, null); // Double[].class, Number[].class);
    enum DataTypeDesc NUMERIC = DataTypeDesc(1700, false, null); // Numeric.class, Number.class);
    enum DataTypeDesc NUMERIC_ARRAY = DataTypeDesc(1231, false, null); // Numeric[].class, Number[].class);
    enum DataTypeDesc MONEY = DataTypeDesc(790, true, null); // Object.class);
    enum DataTypeDesc MONEY_ARRAY = DataTypeDesc(791, true, null); // Object[].class);
    enum DataTypeDesc BIT = DataTypeDesc(1560, true, null); // Object.class);
    enum DataTypeDesc BIT_ARRAY = DataTypeDesc(1561, true, null); // Object[].class);
    enum DataTypeDesc VARBIT = DataTypeDesc(1562, true, null); // Object.class);
    enum DataTypeDesc VARBIT_ARRAY = DataTypeDesc(1563, true, null); // Object[].class);
    enum DataTypeDesc CHAR = DataTypeDesc(18, true, null); // String.class);
    enum DataTypeDesc CHAR_ARRAY = DataTypeDesc(1002, true, null); // String[].class);
    enum DataTypeDesc VARCHAR = DataTypeDesc(1043, true, null); // String.class);
    enum DataTypeDesc VARCHAR_ARRAY = DataTypeDesc(1015, true, null); // String[].class);
    enum DataTypeDesc BPCHAR = DataTypeDesc(1042, true, null); // String.class);
    enum DataTypeDesc BPCHAR_ARRAY = DataTypeDesc(1014, true, null); // String[].class);
    enum DataTypeDesc TEXT = DataTypeDesc(25, true, null); // String.class);
    enum DataTypeDesc TEXT_ARRAY = DataTypeDesc(1009, true, null); // String[].class);
    enum DataTypeDesc NAME = DataTypeDesc(19, true, null); // String.class);
    enum DataTypeDesc NAME_ARRAY = DataTypeDesc(1003, true, null); // String[].class);
    enum DataTypeDesc DATE = DataTypeDesc(1082, true, null); // LocalDate.class);
    enum DataTypeDesc DATE_ARRAY = DataTypeDesc(1182, true, null); // LocalDate[].class);
    enum DataTypeDesc TIME = DataTypeDesc(1083, true, null); // LocalTime.class);
    enum DataTypeDesc TIME_ARRAY = DataTypeDesc(1183, true, null); // LocalTime[].class);
    enum DataTypeDesc TIMETZ = DataTypeDesc(1266, true, null); // OffsetTime.class);
    enum DataTypeDesc TIMETZ_ARRAY = DataTypeDesc(1270, true, null); // OffsetTime[].class);
    enum DataTypeDesc TIMESTAMP = DataTypeDesc(1114, true, null); // LocalDateTime.class);
    enum DataTypeDesc TIMESTAMP_ARRAY = DataTypeDesc(1115, true, null); // LocalDateTime[].class);
    enum DataTypeDesc TIMESTAMPTZ = DataTypeDesc(1184, true, null); // OffsetDateTime.class);
    enum DataTypeDesc TIMESTAMPTZ_ARRAY = DataTypeDesc(1185, true, null); // OffsetDateTime[].class);
    enum DataTypeDesc INTERVAL = DataTypeDesc(1186, true, null); // Interval.class);
    enum DataTypeDesc INTERVAL_ARRAY = DataTypeDesc(1187, true, null); // Interval[].class);
    enum DataTypeDesc BYTEA = DataTypeDesc(17, true, null); // Buffer.class);
    enum DataTypeDesc BYTEA_ARRAY = DataTypeDesc(1001, true, null); // Buffer[].class);
    enum DataTypeDesc MACADDR = DataTypeDesc(829, true, null); // Object.class);
    enum DataTypeDesc INET = DataTypeDesc(869, true, null); // Object[].class);
    enum DataTypeDesc CIDR = DataTypeDesc(650, true, null); // Object.class);
    enum DataTypeDesc MACADDR8 = DataTypeDesc(774, true, null); // Object[].class);
    enum DataTypeDesc UUID = DataTypeDesc(2950, true, null); // UUID.class);
    enum DataTypeDesc UUID_ARRAY = DataTypeDesc(2951, true, null); // UUID[].class);
    enum DataTypeDesc JSON = DataTypeDesc(114, true, null); // Object.class);
    enum DataTypeDesc JSON_ARRAY = DataTypeDesc(199, true, null); // Object[].class);
    enum DataTypeDesc JSONB = DataTypeDesc(3802, true, null); // Object.class);
    enum DataTypeDesc JSONB_ARRAY = DataTypeDesc(3807, true, null); // Object[].class);
    enum DataTypeDesc XML = DataTypeDesc(142, true, null); // Object.class);
    enum DataTypeDesc XML_ARRAY = DataTypeDesc(143, true, null); // Object[].class);
    enum DataTypeDesc POINT = DataTypeDesc(600, true, null); // Point.class);
    enum DataTypeDesc POINT_ARRAY = DataTypeDesc(1017, true, null); // Point[].class);
    enum DataTypeDesc LINE = DataTypeDesc(628, true, null); // Line.class);
    enum DataTypeDesc LINE_ARRAY = DataTypeDesc(629, true, null); // Line[].class);
    enum DataTypeDesc LSEG = DataTypeDesc(601, true, null); // LineSegment.class);
    enum DataTypeDesc LSEG_ARRAY = DataTypeDesc(1018, true, null); // LineSegment[].class);
    enum DataTypeDesc BOX = DataTypeDesc(603, true, null); // Box.class);
    enum DataTypeDesc BOX_ARRAY = DataTypeDesc(1020, true, null); // Box[].class);
    enum DataTypeDesc PATH = DataTypeDesc(602, true, null); // Path.class);
    enum DataTypeDesc PATH_ARRAY = DataTypeDesc(1019, true, null); // Path[].class);
    enum DataTypeDesc POLYGON = DataTypeDesc(604, true, null); // Polygon.class);
    enum DataTypeDesc POLYGON_ARRAY = DataTypeDesc(1027, true, null); // Polygon[].class);
    enum DataTypeDesc CIRCLE = DataTypeDesc(718, true, null); // Circle.class);
    enum DataTypeDesc CIRCLE_ARRAY = DataTypeDesc(719, true, null); // Circle[].class);
    enum DataTypeDesc HSTORE = DataTypeDesc(33670, true, null); // Object.class);
    enum DataTypeDesc OID = DataTypeDesc(26, true, null); // Object.class);
    enum DataTypeDesc OID_ARRAY = DataTypeDesc(1028, true, null); // Object[].class);
    enum DataTypeDesc VOID = DataTypeDesc(2278, true, null); // Object.class);
    enum DataTypeDesc UNKNOWN = DataTypeDesc(705, false, null); // String.class);

    mixin ValuesMemberTempate!DataTypeDesc;

    static DataTypeDesc valueOf(int oid) {
        foreach(ref DataTypeDesc d; values()) {
            if(d.id == oid)
                return d;
        }
        version(HUNT_DEBUG) {
            import hunt.logging.ConsoleLogger;
            warningf("Postgres type OID= %d not handled - using unknown type instead", oid);
        }
        return UNKNOWN;
    }
}