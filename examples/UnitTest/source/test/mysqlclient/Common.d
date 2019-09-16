module test.mysqlclient.Common;


mixin template TestSettingTemplate() {

    import hunt.database.base;
    import hunt.database.driver.mysql;
    import hunt.database.driver.mysql.impl;
    import hunt.logging.ConsoleLogger;
    import core.thread;

    MySQLConnectOptions options;
    SqlConnection currentConnection;

    this() {
        MySQLCollation collation = MySQLCollation.utf8_general_ci;

        options = new MySQLConnectOptions();
        // options.setHost("10.1.11.31");
        // options.setPort(3306);
        // options.setUser("dev");
        // options.setPassword("111111");
        options.setHost("10.1.222.120");
        options.setPort(3306);
        options.setUser("mysql");
        options.setPassword("123456789");        
        options.setDatabase("mysql_test");
        options.setCollation(collation.name());
    }

    override protected void initConnector() {
        if(currentConnection is null) {
            trace("Initializing connect ...");
            MySQLConnectionImpl.connect(options, (AsyncResult!MySQLConnection ar) {
                // mapping MySQLConnection to SqlConnection
                // handler(ar.map!(SqlConnection)( p => p));

                if(ar.succeeded()) {
                    currentConnection = ar.result();
                } else {
                    warning(ar.cause().msg);
                }
            });

        } 

        while(currentConnection is null) {
            Thread.yield();
        }

        connector = (handler) {
            handler(currentConnection);
        };
    }

    override protected void closeConnector() {
        currentConnection.close();
        currentConnection = null;
    }
}