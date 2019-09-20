module hunt.database.driver.mysql.MySQLUtil;

import std.array;

/**
 * 
 */
class MySQLUtil {

    static string escapeWithQuotes(string value) {
        return "\"" ~ escapeLiteral(value) ~ "\"";
    }

    /**
     * Escape a string literal.
     * 
     * @param s
     *            literal
     * @return escaped literal
     */
    static string escapeLiteral(string s) {
        // https://stackoverflow.com/questions/1812891/java-escape-string-to-prevent-sql-injection?noredirect=1&lq=1
        // return s.replace("\"", "\"\"");
        // FIXME: Needing refactor or cleanup -@zxp at Fri, 20 Sep 2019 05:54:46 GMT
        // 
        string data = null;
        if (str.empty()) {
            str = str.replace("\\", "\\\\");
            str = str.replace("'", "\\'");
            str = str.replace("\0", "\\0");
            str = str.replace("\n", "\\n");
            str = str.replace("\r", "\\r");
            str = str.replace("\"", "\\\"");
            str = str.replace("\\x1a", "\\Z");
            data = str;
        }
        return data;        
    }    
 
}