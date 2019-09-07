module test.mysqlclient.MySQLPreparedQueryTestBase;

import test.PreparedQueryTestBase;
import hunt.util.UnitTest;
import std.array;
import std.conv;


abstract class MySQLPreparedQueryTestBase : PreparedQueryTestBase {

    override
    protected string statement(string[] parts... ) {
        Appender!string sb;
        for (size_t i = 0; i < parts.length; i++) {
            if (i > 0) {
                sb.put("?");
            }
            sb.put(parts[i]);
        }
        return sb.data;
    }

    // @Test
    // override
    // void testPreparedQueryParamCoercionTypeError() {
    //     // Does not pass, we can't achieve this feature on MySQL for now, see io.vertx.mysqlclient.impl.codec.MySQLParamDesc#prepare for reasons.
    //     // super.testPreparedQueryParamCoercionTypeError();
    //     closeConnector();
    // }
}
