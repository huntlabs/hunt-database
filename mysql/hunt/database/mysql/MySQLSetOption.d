module hunt.database.mysql.MySQLSetOption;


/**
 * MySQL set options which can be used by {@link MySQLConnection#setOption(MySQLSetOption, Handler)}.
 */
enum MySQLSetOption {
    MYSQL_OPTION_MULTI_STATEMENTS_ON,
    MYSQL_OPTION_MULTI_STATEMENTS_OFF
}
