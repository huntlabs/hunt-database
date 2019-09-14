module hunt.database.driver.mysql.MySQLPool;

import hunt.database.driver.mysql.impl.MySQLPoolImpl;
import hunt.database.driver.mysql.MySQLConnectOptions;

import hunt.database.base.AsyncResult;
import hunt.database.base.PoolOptions;
import hunt.database.base.Pool;
import hunt.database.base.Row;
import hunt.database.base.RowSet;
import hunt.database.base.SqlResult;
import hunt.database.base.Tuple;

import hunt.collection.List;

/**
 * A pool of MySQL connections.
 */
interface MySQLPool : Pool {

    /**
     * Like {@link #pool(String, PoolOptions)} with a default {@code poolOptions}.
     */
    // static MySQLPool pool(String connectionUri) {
    //     return pool(connectionUri, new PoolOptions());
    // }

    /**
     * Like {@link #pool(MySQLConnectOptions, PoolOptions)} with {@code connectOptions} build from {@code connectionUri}.
     */
    // static MySQLPool pool(String connectionUri, PoolOptions poolOptions) {
    //     return pool(fromUri(connectionUri), poolOptions);
    // }

    /**
     * Like {@link #pool(Vertx, MySQLConnectOptions, PoolOptions)} with {@code connectOptions} build from {@code connectionUri}.
     */
    // static MySQLPool pool(String connectionUri, PoolOptions poolOptions) {
    //     return pool(vertx, fromUri(connectionUri), poolOptions);
    // }

    /**
     * Create a connection pool to the MySQL server configured with the given {@code connectOptions} and {@code poolOptions}.
     *
     * @param connectOptions the options for the connection
     * @param poolOptions the options for creating the pool
     * @return the connection pool
     */
    // static MySQLPool pool(MySQLConnectOptions connectOptions, PoolOptions poolOptions) {
    //     if (Vertx.currentContext() !is null) {
    //         throw new IllegalStateException("Running in a Vertx context => use MySQLPool#pool(Vertx, MySQLConnectOptions, PoolOptions) instead");
    //     }
    //     VertxOptions vertxOptions = new VertxOptions();
    //     Vertx vertx = Vertx.vertx(vertxOptions);
    //     return new MySQLPoolImpl(vertx.getOrCreateContext(), true, connectOptions, poolOptions);
    // }

    /**
     * Like {@link #pool(MySQLConnectOptions, PoolOptions)} with a specific {@link Vertx} instance.
     */
    static MySQLPool pool(MySQLConnectOptions connectOptions, PoolOptions poolOptions) {
        return new MySQLPoolImpl(connectOptions, poolOptions);
    }

    // override
    // MySQLPool preparedQuery(String sql, RowSetHandler handler);


    // override
    // <R> MySQLPool preparedQuery(String sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // MySQLPool query(String sql, RowSetHandler handler);


    // override
    // <R> MySQLPool query(String sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // MySQLPool preparedQuery(String sql, Tuple arguments, RowSetHandler handler);


    // override
    // <R> MySQLPool preparedQuery(String sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // MySQLPool preparedBatch(String sql, List!(Tuple) batch, RowSetHandler handler);


    // override
    // <R> MySQLPool preparedBatch(String sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
}
