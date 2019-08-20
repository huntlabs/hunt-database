/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.postgresql.PostgreSQLPool;

import hunt.database.postgresql.PostgreSQLConnectOptions;
import hunt.database.postgresql.impl.PostgreSQLPoolImpl;


import hunt.database.base.PoolOptions;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.Pool;
import hunt.database.base.Tuple;
import hunt.database.base.AsyncResult;

// import io.vertx.core.Handler;
// import io.vertx.core.Vertx;
// import io.vertx.core.VertxOptions;

// import hunt.collection.List;
// import java.util.stream.Collector;

/**
 * A pool of PostgreSQL connections.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
interface PgPool : Pool {

    /**
     * Like {@link #pool(PoolOptions)} with a default {@code poolOptions}.
     */
    // static PgPool pool() {
    //     return pool(PgConnectOptions.fromEnv(), new PoolOptions());
    // }

    /**
     * Like {@link #pool(PgConnectOptions, PoolOptions)} with {@code connectOptions} build from the environment variables.
     */
    // static PgPool pool(PoolOptions poolOptions) {
    //     return pool(PgConnectOptions.fromEnv(), poolOptions);
    // }

    /**
     * Like {@link #pool(string, PoolOptions)} with a default {@code poolOptions}.
     */
    static PgPool pool(string connectionUri) {
        return pool(connectionUri, new PoolOptions());
    }

    /**
     * Like {@link #pool(PgConnectOptions, PoolOptions)} with {@code connectOptions} build from {@code connectionUri}.
     */
    // static PgPool pool(string connectionUri, PoolOptions poolOptions) {
    //     return pool(PgConnectOptions.fromUri(connectionUri), poolOptions);
    // }

    /**
     * Like {@link #pool(Vertx, PgConnectOptions, PoolOptions)} with {@code connectOptions} build from the environment variables.
     */
    // static PgPool pool(Vertx vertx, PoolOptions poolOptions) {
    //     return pool(vertx, PgConnectOptions.fromEnv(), poolOptions);
    // }

    /**
     * Like {@link #pool(Vertx, PgConnectOptions, PoolOptions)} with {@code connectOptions} build from {@code connectionUri}.
     */
    // static PgPool pool(Vertx vertx, string connectionUri, PoolOptions poolOptions) {
    //     return pool(vertx, PgConnectOptions.fromUri(connectionUri), poolOptions);
    // }

    /**
     * Create a connection pool to the database configured with the given {@code connectOptions} and {@code poolOptions}.
     *
     * @param poolOptions the options for creating the pool
     * @return the connection pool
     */
    // static PgPool pool(PgConnectOptions connectOptions, PoolOptions poolOptions) {
    //     if (Vertx.currentContext() !is null) {
    //         throw new IllegalStateException("Running in a Vertx context => use PgPool#pool(Vertx, PgConnectOptions, PoolOptions) instead");
    //     }
    //     VertxOptions vertxOptions = new VertxOptions();
    //     if (connectOptions.isUsingDomainSocket()) {
    //         vertxOptions.setPreferNativeTransport(true);
    //     }
    //     Vertx vertx = Vertx.vertx(vertxOptions);
    //     return new PgPoolImpl(vertx.getOrCreateContext(), true, connectOptions, poolOptions);
    // }

    /**
     * Like {@link #pool(PgConnectOptions, PoolOptions)} with a specific {@link Vertx} instance.
     */
    // static PgPool pool(Vertx vertx, PgConnectOptions connectOptions, PoolOptions poolOptions) {
    //     return new PgPoolImpl(vertx.getOrCreateContext(), false, connectOptions, poolOptions);
    // }

    PgPool preparedQuery(string sql, RowSetHandler handler);


    // <R> PgPool preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgPool query(string sql, RowSetHandler handler);


    // <R> PgPool query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgPool preparedQuery(string sql, Tuple arguments, RowSetHandler handler);


    // <R> PgPool preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgPool preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler);


    // <R> PgPool preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

}
