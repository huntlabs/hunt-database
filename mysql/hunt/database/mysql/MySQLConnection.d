module hunt.database.mysql.MySQLConnection;

import hunt.database.mysql.MySQLConnectOptions;
import hunt.database.mysql.MySQLSetOption;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
// import hunt.database.mysql.impl.MySQLConnectionImpl;
import hunt.database.base.PreparedQuery;
import hunt.database.base.Row;
import hunt.database.base.RowSet;
import hunt.database.base.SqlConnection;
import hunt.database.base.SqlResult;
import hunt.database.base.Tuple;

/**
 * A connection to MySQL server.
 */
interface MySQLConnection : SqlConnection {
    /**
     * Create a connection to MySQL server with the given {@code connectOptions}.
     *
     * @param vertx the vertx instance
     * @param connectOptions the options for the connection
     * @param handler the handler called with the connection or the failure
     */
    // static void connect(MySQLConnectOptions connectOptions, AsyncResultHandler!(MySQLConnection)) handler) {
    //     MySQLConnectionImpl.connect(connectOptions, handler);
    // }

    /**
     * Like {@link #connect(Vertx, MySQLConnectOptions, Handler)} with options build from {@code connectionUri}.
     */
    // static void connect(string connectionUri, AsyncResultHandler!(MySQLConnection)) handler) {
    //     connect(fromUri(connectionUri), handler);
    // }


    // MySQLConnection prepare(string sql, PreparedQueryHandler handler);

    // MySQLConnection exceptionHandler(ExceptionHandler handler);

    // MySQLConnection closeHandler(VoidHandler handler);

    // MySQLConnection preparedQuery(string sql, RowSetHandler handler);


    // <R> MySQLConnection preparedQuery(string sql, Collector<Row, ?, R> collector, AsyncResultHandler!(SqlResult!(R))) handler);


    MySQLConnection query(string sql, RowSetHandler handler);



    // <R> MySQLConnection query(string sql, Collector<Row, ?, R> collector, AsyncResultHandler!(SqlResult!(R))) handler);


    MySQLConnection preparedQuery(string sql, Tuple arguments, RowSetHandler handler);


    // <R> MySQLConnection preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, AsyncResultHandler!(SqlResult!(R))) handler);

    /**
     * Send a PING command to check if the server is alive.
     *
     * @param handler the handler notified when the server responses to client
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection ping(VoidHandler handler);

    /**
     * Send a INIT_DB command to change the default schema of the connection.
     *
     * @param schemaName name of the schema to change to
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection specifySchema(string schemaName, VoidHandler handler);

    /**
     * Send a STATISTICS command to get a human readable string of the server internal status.
     *
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection getInternalStatistics(AsyncResultHandler!(string) handler);


    /**
     * Send a SET_OPTION command to set options for the current connection.
     *
     * @param option the options to set
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection setOption(MySQLSetOption option, VoidHandler handler);

    /**
     * Send a RESET_CONNECTION command to reset the session state.
     *
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection resetConnection(VoidHandler handler);

    /**
     * Send a DEBUG command to dump debug information to the server's stdout.
     *
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection dumpDebug(VoidHandler handler);

    /**
     * Send a CHANGE_USER command to change the user of the current connection, this operation will also reset connection state.
     *
     * @param options authentication options, only username, password, database, collation and properties will be used.
     * @param handler the handler
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnection changeUser(MySQLConnectOptions options, VoidHandler handler);
}
