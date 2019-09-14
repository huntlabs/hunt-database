module test.mysqlclient.MySQLQueryTest;

import test.mysqlclient.Common;
import test.mysqlclient.MySQLTestBase;
import test.Common;

import hunt.database.base;
import hunt.database.driver.mysql;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.text.Charset;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.util.ConverterUtils;

import core.atomic;
import std.ascii;
import std.conv;
import std.format;
import std.uuid;
import std.variant;


/**
 * We need to decide which part of these test to be migrated into TCK.
 * TODO shall we have collector tests in TCK? collector is more a feature for upper application rather than driver SPI feature
 */
class MySQLQueryTest : MySQLTestBase {

    
    mixin TestSettingTemplate;

    @Before
    void setup() {
        initConnector();
    }

    @After
    void teardown() {
        // vertx.close(ctx.asyncAssertSuccess());
    }


    // @Test
    // void testLastInsertIdWithDefaultValue() {
    //     connector((SqlConnection conn) {
    //         string sql = "CREATE TEMPORARY TABLE last_insert_id(id INTEGER PRIMARY KEY AUTO_INCREMENT, val VARCHAR(20));";
    //         conn.query(sql, (AsyncResult!RowSet ar) {
    //             trace("running here");
    //             RowSet createTableResult = asyncAssertSuccess(ar);
    //             Variant value1 = createTableResult.property(MySQLClient.LAST_INSERTED_ID);
    //             if(value1.type != typeid(int)) {
    //                 warning("Not expected type: ", value1.type);
    //             } else {
    //                 int lastInsertId1 = value1.get!int();
    //                 assert(0 == lastInsertId1);
    //             }
    //             conn.query("INSERT INTO last_insert_id(val) VALUES('test')", (AsyncResult!RowSet ar2) {
    //                 trace("running here");
    //                 RowSet insertResult1 = asyncAssertSuccess(ar2);
                    
    //                 Variant value2 = insertResult1.property(MySQLClient.LAST_INSERTED_ID);
    //                 if(value2.type != typeid(int)) {
    //                     warning("Not expected type: ", value2.type);
    //                 } else {
    //                     int lastInsertId2 = value2.get!int();
    //                     assert(1 == lastInsertId2);
    //                 }
    //                 conn.query("INSERT INTO last_insert_id(val) VALUES('test2')", (AsyncResult!RowSet ar3) {
    //                     trace("running here");
    //                     RowSet insertResult2 = asyncAssertSuccess(ar3);
                        
    //                     Variant value3 = insertResult2.property(MySQLClient.LAST_INSERTED_ID);
    //                     if(value2.type != typeid(int)) {
    //                         warning("Not expected type: ", value3.type);
    //                     } else {
    //                         int lastInsertId3 = value3.get!int();
    //                         assert(2 == lastInsertId3);
    //                     }
    //                     conn.close();
    //                 });
    //             });
    //         });
    //     });
    // }

    // @Test
    // void testLastInsertIdWithSpecifiedValue() {
    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.query("CREATE TEMPORARY TABLE last_insert_id(id INTEGER PRIMARY KEY AUTO_INCREMENT, val VARCHAR(20));", (AsyncResult!RowSet ar) {
    //             int lastInsertId1 = createTableResult.property(MySQLClient.LAST_INSERTED_ID);
    //             assert(0, lastInsertId1);
    //             conn.query("ALTER TABLE last_insert_id AUTO_INCREMENT=1234", ctx.asyncAssertSuccess(alterTableResult -> {
    //                 int lastInsertId2 = createTableResult.property(MySQLClient.LAST_INSERTED_ID);
    //                 assert(0, lastInsertId2);
    //                 conn.query("INSERT INTO last_insert_id(val) VALUES('test')", ctx.asyncAssertSuccess(insertResult1 -> {
    //                     int lastInsertId3 = insertResult1.property(MySQLClient.LAST_INSERTED_ID);
    //                     assert(1234, lastInsertId3);
    //                     conn.query("INSERT INTO last_insert_id(val) VALUES('test2')", ctx.asyncAssertSuccess(insertResult2 -> {
    //                         int lastInsertId4 = insertResult2.property(MySQLClient.LAST_INSERTED_ID);
    //                         assert(1235, lastInsertId4);
    //                         conn.close();
    //                     }));
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    @Test
    void testCachePreparedStatementWithDifferentSql() {
        // we set the cache size to be the same with max_prepared_stmt_count
        options.setCachePreparedStatements(true)
            .setPreparedStatementCacheMaxSize(16382);

        connector((SqlConnection conn) {
            string sql = "SHOW VARIABLES LIKE 'max_prepared_stmt_count'";
            conn.query(sql, (AsyncResult!RowSet ar) {
                trace("running here");
                RowSet res1 = asyncAssertSuccess(ar);
                RowIterator iterator1 = res1.iterator();
                Row row = iterator1.front();
                iterator1.popFront();
                
                assert("max_prepared_stmt_count" == row.getString(0));
                string str = row.getString(1);
                int maxPreparedStatementCount = to!int(str);
                assert(16382 == maxPreparedStatementCount);

                // FIXME: Needing refactor or cleanup -@zxp at 9/5/2019, 6:15:58 PM
                // may fail
                for (int i = 0; i < 3; i++) {
                    string randomString = randomUUID().toString();
                    for (int j = 0; j < 2; j++) {
                        conn.preparedQuery("SELECT '" ~ randomString ~ "'", (AsyncResult!RowSet ar2) {
                            trace("randomString: " ~ randomString);
                            RowSet res2 = asyncAssertSuccess(ar2);
                            RowIterator iterator2 = res2.iterator();
                            Row row2 = iterator2.front();
                            iterator2.popFront();
                            assert(randomString == row2.getString(0));
                        });
                    }
                }
            });
        });
    }

    // @Test
    // void testCachePreparedStatementWithSameSql() {
    //     MySQLConnection.connect(options.setCachePreparedStatements(true), ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SHOW VARIABLES LIKE 'max_prepared_stmt_count'", ctx.asyncAssertSuccess(res1 -> {
    //             Row row = res1.iterator().next();
    //             int maxPreparedStatementCount = Integer.parseInt(row.getString(1));
    //             assert("max_prepared_stmt_count", row.getString(0));
    //             assert(16382, maxPreparedStatementCount);

    //             for (int i = 0; i < 20000; i++) {
    //                 conn.preparedQuery("SELECT 'test'", ctx.asyncAssertSuccess(res2 -> {
    //                     assert("test", res2.iterator().next().getString(0));
    //                 }));
    //             }
    //         }));
    //     }));
    // }

    // @Test
    // void testDecodePacketSizeMoreThan16MB() {
    //     StringBuilder sb = new StringBuilder();
    //     for (int i = 0; i < 4000000; i++) {
    //         sb.append("abcde");
    //     }
    //     string expected = sb.toString();

    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SELECT REPEAT('abcde', 4000000)", ctx.asyncAssertSuccess(rowSet -> {
    //             assert(1, rowSet.size());
    //             Row row = rowSet.iterator().next();
    //             ctx.assertTrue(row.getString(0).getBytes().length > 0xFFFFFF);
    //             assert(expected, row.getValue(0));
    //             assert(expected, row.getString(0));
    //             conn.close();
    //         }));
    //     }));
    // }

    // @Test
    // void testEncodePacketSizeMoreThan16MB() {
    //     int dataSize = 20 * 1024 * 1024; // 20MB payload
    //     byte[] data = new byte[dataSize];
    //     ThreadLocalRandom.current().nextBytes(data);
    //     Buffer buffer = Buffer.buffer(data);
    //     ctx.assertTrue(buffer.length() > 0xFFFFFF);

    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery("UPDATE datatype SET `LongBlob` = ? WHERE id = 2", Tuple.of(buffer), ctx.asyncAssertSuccess(v -> {
    //             conn.preparedQuery("SELECT id, `LongBlob` FROM datatype WHERE id = 2", ctx.asyncAssertSuccess(rowSet -> {
    //                 Row row = rowSet.iterator().next();
    //                 assert(2, row.getInteger(0));
    //                 assert(2, row.getInteger("id"));
    //                 assert(buffer, row.getBuffer(1));
    //                 assert(buffer, row.getBuffer("LongBlob"));
    //                 conn.close();
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testMultiResult() {
    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SELECT 1; SELECT \'test\';", ctx.asyncAssertSuccess(result -> {
    //             Row row1 = result.iterator().next();
    //             assert(1, row1.getInteger(0));
    //             Row row2 = result.next().iterator().next();
    //             assert("test", row2.getValue(0));
    //             assert("test", row2.getString(0));
    //             conn.close();
    //         }));
    //     }));
    // }

    // @Test
    // void testSimpleQueryCollector() {
    //     Collector<Row, ?, Map!(Integer, DummyObject)> collector = Collectors.toMap(
    //         row -> row.getInteger("id"),
    //         row -> new DummyObject(row.getInteger("id"),
    //             row.getShort("Int2"),
    //             row.getInteger("Int3"),
    //             row.getInteger("Int4"),
    //             row.getLong("Int8"),
    //             row.getFloat("Float"),
    //             row.getDouble("Double"),
    //             row.getString("Varchar"))
    //     );

    //     DummyObject expected = new DummyObject(1, (short) 32767, 8388607, 2147483647, 9223372036854775807L,
    //         123.456f, 1.234567d, "HELLO,WORLD");

    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SELECT * FROM collectorTest WHERE id = 1", collector, ctx.asyncAssertSuccess(result -> {
    //             Map!(Integer, DummyObject) map = result.value();
    //             DummyObject actual = map.get(1);
    //             assert(expected, actual);
    //             conn.close();
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedCollector() {
    //     Collector<Row, ?, Map!(Integer, DummyObject)> collector = Collectors.toMap(
    //         row -> row.getInteger("id"),
    //         row -> new DummyObject(row.getInteger("id"),
    //             row.getShort("Int2"),
    //             row.getInteger("Int3"),
    //             row.getInteger("Int4"),
    //             row.getLong("Int8"),
    //             row.getFloat("Float"),
    //             row.getDouble("Double"),
    //             row.getString("Varchar"))
    //     );

    //     DummyObject expected = new DummyObject(1, (short) 32767, 8388607, 2147483647, 9223372036854775807L,
    //         123.456f, 1.234567d, "HELLO,WORLD");

    //     MySQLConnection.connect(options, ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery("SELECT * FROM collectorTest WHERE id = ?", Tuple.of(1), collector, ctx.asyncAssertSuccess(result -> {
    //             Map!(Integer, DummyObject) map = result.value();
    //             DummyObject actual = map.get(1);
    //             assert(expected, actual);
    //             conn.close();
    //         }));
    //     }));
    // }
}



// this class is for verifying the use of Collector API
// class DummyObject {
//     private int id;
//     private short int2;
//     private int int3;
//     private int int4;
//     private long int8;
//     private float floatNum;
//     private double doubleNum;
//     private string varchar;

//     this(int id, short int2, int int3, int int4, long int8, float floatNum, double doubleNum, string varchar) {
//         this.id = id;
//         this.int2 = int2;
//         this.int3 = int3;
//         this.int4 = int4;
//         this.int8 = int8;
//         this.floatNum = floatNum;
//         this.doubleNum = doubleNum;
//         this.varchar = varchar;
//     }

//     int getId() {
//         return id;
//     }

//     void setId(int id) {
//         this.id = id;
//     }

//     short getInt2() {
//         return int2;
//     }

//     void setInt2(short int2) {
//         this.int2 = int2;
//     }

//     int getInt3() {
//         return int3;
//     }

//     void setInt3(int int3) {
//         this.int3 = int3;
//     }

//     int getInt4() {
//         return int4;
//     }

//     void setInt4(int int4) {
//         this.int4 = int4;
//     }

//     long getInt8() {
//         return int8;
//     }

//     void setInt8(long int8) {
//         this.int8 = int8;
//     }

//     float getFloatNum() {
//         return floatNum;
//     }

//     void setFloatNum(float floatNum) {
//         this.floatNum = floatNum;
//     }

//     double getDoubleNum() {
//         return doubleNum;
//     }

//     void setDoubleNum(double doubleNum) {
//         this.doubleNum = doubleNum;
//     }

//     string getVarchar() {
//         return varchar;
//     }

//     void setVarchar(string varchar) {
//         this.varchar = varchar;
//     }

//     override
//     boolean equals(Object o) {
//         if (this == o) return true;
//         if (o == null || getClass() != o.getClass()) return false;

//         DummyObject that = (DummyObject) o;

//         if (id != that.id) return false;
//         if (int2 != that.int2) return false;
//         if (int3 != that.int3) return false;
//         if (int4 != that.int4) return false;
//         if (int8 != that.int8) return false;
//         if (Float.compare(that.floatNum, floatNum) != 0) return false;
//         if (Double.compare(that.doubleNum, doubleNum) != 0) return false;
//         return varchar != null ? varchar == that.varchar : that.varchar == null;
//     }

//     override
//     size_t toHash() @trusted nothrow {
//         int result;
//         long temp;
//         result = id;
//         result = 31 * result + (int) int2;
//         result = 31 * result + int3;
//         result = 31 * result + int4;
//         result = 31 * result + (int) (int8 ^ (int8 >>> 32));
//         result = 31 * result + (floatNum != +0.0f ? Float.floatToIntBits(floatNum) : 0);
//         temp = Double.doubleToLongBits(doubleNum);
//         result = 31 * result + (int) (temp ^ (temp >>> 32));
//         result = 31 * result + (varchar != null ? varchar.hashCode() : 0);
//         return result;
//     }

//     override
//     string toString() {
//         return "DummyObject{" ~
//             "id=" ~ id +
//             ", int2=" ~ int2 +
//             ", int3=" ~ int3 +
//             ", int4=" ~ int4 +
//             ", int8=" ~ int8 +
//             ", floatNum=" ~ floatNum +
//             ", doubleNum=" ~ doubleNum +
//             ", varchar='" ~ varchar + '\'' +
//             '}';
//     }
// }