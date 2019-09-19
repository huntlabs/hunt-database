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

module hunt.database.base.Pool;

import hunt.database.base.AsyncResult;
import hunt.database.base.SqlClient;
import hunt.database.base.SqlConnection;

import hunt.collection.List;
import hunt.concurrency.Future;

/**
 * A pool of SQL connections.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
interface Pool : SqlClient {

//     override
//     Pool preparedQuery(string sql, RowSetHandler handler);

//     override
//     <R> Pool preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

//     override
//     Pool query(string sql, RowSetHandler handler);

//     override
//     <R> Pool query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

//     override
//     Pool preparedQuery(string sql, Tuple arguments, RowSetHandler handler);

//     override
//     <R> Pool preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

//     override
//     Pool preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler);

//     override
//     <R> Pool preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Get a connection from the pool.
     *
     * @param handler the handler that will get the connection result
     */
    void getConnection(AsyncSqlConnectionHandler handler);


    Future!(SqlConnection) getConnectionAsync();

    SqlConnection getConnection();

//     /**
//      * Borrow a connection from the pool and begin a transaction, the underlying connection will be returned
//      * to the pool when the transaction ends.
//      *
//      * @return the transaction
//      */
//     void begin(Handler!(AsyncResult!(Transaction)) handler);

    /**
     * Close the pool and release the associated resources.
     */
    void close();

}
