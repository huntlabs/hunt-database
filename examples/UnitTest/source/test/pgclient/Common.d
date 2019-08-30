module test.pgclient.Common;


mixin template TestSettingTemplate() {

    import hunt.database.base;
    import hunt.database.postgresql;
    import hunt.database.postgresql.impl;
    import hunt.logging.ConsoleLogger;

    PgConnectOptions options;

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
        connector = (handler) {
            trace("Initializing connect ...");
            PgConnectionImpl.connect(options, (AsyncResult!PgConnection ar) {
                // mapping PgConnection to SqlConnection
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