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

module hunt.database.postgresql.PostgreSQLConnection;

import hunt.database.postgresql.impl.PostgreSQLConnectionImpl;
import hunt.database.base.PreparedQuery;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.SqlConnection;
import hunt.database.base.Tuple;

// import io.vertx.codegen.annotations.Fluent;
// import io.vertx.codegen.annotations.GenIgnore;
// import io.vertx.codegen.annotations.VertxGen;
// import io.vertx.core.*;

import hunt.collection.List;
// import java.util.stream.Collector;

/**
 * A connection to Postgres.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
interface PgConnection : SqlConnection {

    /**
     * Connects to the database and returns the connection if that succeeds.
     * <p/>
     * The connection interracts directly with the database is not a proxy, so closing the
     * connection will close the underlying connection to the database.
     *
     * @param vertx the vertx instance
     * @param options the connect options
     * @param handler the handler called with the connection or the failure
     */
    // static void connect(Vertx vertx, PgConnectOptions options, Handler!(AsyncResult!(PgConnection)) handler) {
    //     PgConnectionImpl.connect(vertx, options, handler);
    // }

    /**
     * Like {@link #connect(Vertx, PgConnectOptions, Handler)} with options build from the environment variables.
     */
    // static void connect(Vertx vertx, Handler!(AsyncResult!(PgConnection)) handler) {
    //     connect(vertx, PgConnectOptions.fromEnv(), handler);
    // }

    /**
     * Like {@link #connect(Vertx, PgConnectOptions, Handler)} with options build from {@code connectionUri}.
     */
    // static void connect(Vertx vertx, string connectionUri, Handler!(AsyncResult!(PgConnection)) handler) {
    //     connect(vertx, PgConnectOptions.fromUri(connectionUri), handler);
    // }

    /**
     * Set an handler called when the connection receives notification on a channel.
     * <p/>
     * The handler is called with the {@link PgNotification} and has access to the channel name
     * and the notification payload.
     *
     * @param handler the handler
     * @return the transaction instance
     */
    PgConnection notificationHandler(Handler!(PgNotification) handler);

    /**
     * Send a request cancellation message to tell the server to cancel processing request in this connection.
     * <br>Note: Use this with caution because the cancellation signal may or may not have any effect.
     *
     * @param handler the handler notified if cancelling request is sent
     * @return a reference to this, so the API can be used fluently
     */
    PgConnection cancelRequest(VoidHandler handler);

    /**
     * @return The process ID of the target backend
     */
    int processId();

    /**
     * @return The secret key for the target backend
     */
    int secretKey();

    PgConnection prepare(string sql, Handler!(AsyncResult!(PreparedQuery)) handler);
    PgConnection exceptionHandler(Handler!(Throwable) handler);
    PgConnection closeHandler(Handler!(Void) handler);
    PgConnection preparedQuery(string sql, Handler!(AsyncResult!(RowSet)) handler);


    // <R> PgConnection preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgConnection query(string sql, Handler!(AsyncResult!(RowSet)) handler);


    // <R> PgConnection query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgConnection preparedQuery(string sql, Tuple arguments, Handler!(AsyncResult!(RowSet)) handler);


    // <R> PgConnection preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
    // PgConnection preparedBatch(string sql, List!(Tuple) batch, Handler!(AsyncResult!(RowSet)) handler);


    // <R> PgConnection preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);
}
