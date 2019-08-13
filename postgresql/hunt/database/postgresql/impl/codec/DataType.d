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
module hunt.database.postgresql.impl.codec.DataType;

// import io.netty.util.collection.IntObjectHashMap;
// import io.netty.util.collection.IntObjectMap;

import hunt.database.postgresql.data.Box;
import hunt.database.postgresql.data.Circle;
import hunt.database.postgresql.data.Line;
import hunt.database.postgresql.data.LineSegment;
import hunt.database.postgresql.data.Interval;
import hunt.database.postgresql.data.Path;
import hunt.database.postgresql.data.Point;
import hunt.database.postgresql.data.Polygon;

import hunt.database.base.data.Numeric;

// import io.vertx.core.buffer.Buffer;
// import io.vertx.core.logging.Logger;
// import io.vertx.core.logging.LoggerFactory;

// import java.time.*;
// import java.util.UUID;

/**
 * PostgreSQL <a href="https://github.com/postgres/postgres/blob/master/src/include/catalog/pg_type.h">object
 * identifiers (OIDs)</a> for data types
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
enum DataType {
    BOOL = 16,
    BOOL_ARRAY = 1000,
    INT2 = 21,
    INT2_ARRAY = 1005,
    INT4 = 23,
    INT4_ARRAY = 1007,
    INT8 = 20,
    INT8_ARRAY = 1016,
    FLOAT4 = 700,
    FLOAT4_ARRAY = 1021,
    FLOAT8 = 701,
    FLOAT8_ARRAY = 1022,
    NUMERIC = 1700,
    NUMERIC_ARRAY = 1231,
    MONEY = 790,
    MONEY_ARRAY = 791,
    BIT = 1560,
    BIT_ARRAY = 1561,
    VARBIT = 1562,
    VARBIT_ARRAY = 1563,
    CHAR = 18,
    CHAR_ARRAY = 1002,
    VARCHAR = 1043,
    VARCHAR_ARRAY = 1015,
    BPCHAR = 1042,
    BPCHAR_ARRAY = 1014,
    TEXT = 25,
    TEXT_ARRAY = 1009,
    NAME = 19,
    NAME_ARRAY = 1003,
    DATE = 1082,
    DATE_ARRAY = 1182,
    TIME = 1083,
    TIME_ARRAY = 1183,
    TIMETZ = 1266,
    TIMETZ_ARRAY = 1270,
    TIMESTAMP = 1114,
    TIMESTAMP_ARRAY = 1115,
    TIMESTAMPTZ = 1184,
    TIMESTAMPTZ_ARRAY = 1185,
    INTERVAL = 1186,
    INTERVAL_ARRAY = 1187,
    BYTEA = 17,
    BYTEA_ARRAY = 1001,
    MACADDR = 829,
    INET = 869,
    CIDR = 650,
    MACADDR8 = 774,
    UUID = 2950,
    UUID_ARRAY = 2951,
    JSON = 114,
    JSON_ARRAY = 199,
    JSONB = 3802,
    JSONB_ARRAY = 3807,
    XML = 142,
    XML_ARRAY = 143,
    POINT = 600,
    POINT_ARRAY = 1017,
    LINE = 628,
    LINE_ARRAY = 629,
    LSEG = 601,
    LSEG_ARRAY = 1018,
    BOX = 603,
    BOX_ARRAY = 1020,
    PATH = 602,
    PATH_ARRAY = 1019,
    POLYGON = 604,
    POLYGON_ARRAY = 1027,
    CIRCLE = 718,
    CIRCLE_ARRAY = 719,
    HSTORE = 33670,
    OID = 26,
    OID_ARRAY = 1028,
    VOID = 2278,
    UNKNOWN = 705
}
