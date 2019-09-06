module test.pgclient.Common;


mixin template TestSettingTemplate() {

    import hunt.database.base;
    import hunt.database.postgresql;
    import hunt.database.postgresql.impl;
    import hunt.logging.ConsoleLogger;
    import core.thread;


    PgConnectOptions options;
    SqlConnection currentConnection;

    this() {
        
        options = new PgConnectOptions();
        options.setHost("10.1.11.44");
        // options.setHost("10.1.222.120");
        options.setPort(5432);
        options.setUser("postgres");
        options.setPassword("123456");
        options.setDatabase("postgres");
    }

    override protected void initConnector() {
        if(currentConnection is null) {
            trace("Initializing connect ...");
            PgConnectionImpl.connect(options, (AsyncResult!PgConnection ar) {
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