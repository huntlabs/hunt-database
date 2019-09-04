module test.mysqlclient.Common;


mixin template TestSettingTemplate() {

    import hunt.database.base;
    import hunt.database.mysql;
    import hunt.database.mysql.impl;
    import hunt.logging.ConsoleLogger;

    MySQLConnectOptions options;

    this() {
        MySQLCollation collation = MySQLCollation.utf8_general_ci;

        options = new MySQLConnectOptions();
        options.setHost("10.1.11.31");
        // options.setHost("10.1.222.120");
        options.setPort(3306);
        options.setUser("dev");
        options.setPassword("111111");
        options.setDatabase("mysql_test");
        options.setCollation(collation.name());
    }

    override protected void initConnector() {
        connector = (handler) {
            trace("Initializing connect ...");
            MySQLConnectionImpl.connect(options, (AsyncResult!MySQLConnection ar) {
                // mapping MySQLConnection to SqlConnection
                // handler(ar.map!(SqlConnection)( p => p));

                if(ar.succeeded()) {
                    handler(ar.result());
                } else {
                    warning(ar.cause().msg);
                }
            });
        };
    }
}