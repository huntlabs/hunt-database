module hunt.database.mysql.MySQLConnection;

import io.vertx.codegen.annotations.Fluent;
import io.vertx.codegen.annotations.GenIgnore;
import io.vertx.codegen.annotations.VertxGen;
import hunt.database.base.AsyncResult;
import io.vertx.core.Handler;
import io.vertx.core.Vertx;
import hunt.database.mysql.impl.MySQLConnectionImpl;
import hunt.database.base.PreparedQuery;
import hunt.database.base.Row;
import hunt.database.base.RowSet;
import hunt.database.base.SqlConnection;
import hunt.database.base.SqlResult;
import hunt.database.base.Tuple;

import java.util.stream.Collector;

import static hunt.database.mysql.MySQLConnectOptions.*;

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
  static void connect(Vertx vertx, MySQLConnectOptions connectOptions, Handler!(AsyncResult!(MySQLConnection)) handler) {
    MySQLConnectionImpl.connect(vertx, connectOptions, handler);
  }

  /**
   * Like {@link #connect(Vertx, MySQLConnectOptions, Handler)} with options build from {@code connectionUri}.
   */
  static void connect(Vertx vertx, String connectionUri, Handler!(AsyncResult!(MySQLConnection)) handler) {
    connect(vertx, fromUri(connectionUri), handler);
  }

  override
  MySQLConnection prepare(String sql, Handler!(AsyncResult!(PreparedQuery)) handler);

  override
  MySQLConnection exceptionHandler(Handler!(Throwable) handler);

  override
  MySQLConnection closeHandler(VoidHandler handler);

  override
  MySQLConnection preparedQuery(String sql, RowSetHandler handler);

  @GenIgnore
  override
  <R> MySQLConnection preparedQuery(String sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

  override
  MySQLConnection query(String sql, RowSetHandler handler);

  @GenIgnore
  override
  <R> MySQLConnection query(String sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

  override
  MySQLConnection preparedQuery(String sql, Tuple arguments, RowSetHandler handler);

  @GenIgnore
  override
  <R> MySQLConnection preparedQuery(String sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

  /**
   * Send a PING command to check if the server is alive.
   *
   * @param handler the handler notified when the server responses to client
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection ping(VoidHandler handler);

  /**
   * Send a INIT_DB command to change the default schema of the connection.
   *
   * @param schemaName name of the schema to change to
   * @param handler the handler notified with the execution result
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection specifySchema(String schemaName, VoidHandler handler);

  /**
   * Send a STATISTICS command to get a human readable string of the server internal status.
   *
   * @param handler the handler notified with the execution result
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection getInternalStatistics(Handler!(AsyncResult!(String)) handler);


  /**
   * Send a SET_OPTION command to set options for the current connection.
   *
   * @param option the options to set
   * @param handler the handler notified with the execution result
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection setOption(MySQLSetOption option, VoidHandler handler);

  /**
   * Send a RESET_CONNECTION command to reset the session state.
   *
   * @param handler the handler notified with the execution result
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection resetConnection(VoidHandler handler);

  /**
   * Send a DEBUG command to dump debug information to the server's stdout.
   *
   * @param handler the handler notified with the execution result
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection debug(VoidHandler handler);

  /**
   * Send a CHANGE_USER command to change the user of the current connection, this operation will also reset connection state.
   *
   * @param options authentication options, only username, password, database, collation and properties will be used.
   * @param handler the handler
   * @return a reference to this, so the API can be used fluently
   */
  @Fluent
  MySQLConnection changeUser(MySQLConnectOptions options, VoidHandler handler);
}
