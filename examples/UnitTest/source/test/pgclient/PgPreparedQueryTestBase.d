module test.pgclient.PgPreparedQueryTestBase;

import test.PreparedQueryTestBase;
import std.array;
import std.conv;

abstract class PgPreparedQueryTestBase : PreparedQueryTestBase {

    override
    protected string statement(string[] parts... ) {
        Appender!string sb;
        for (size_t i = 0; i < parts.length; i++) {
            if (i > 0) {
                sb.put("$");
                sb.put(i.to!string());
            }
            sb.put(parts[i]);
        }
        return sb.data;
    }
}
