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

module hunt.database.base.SqlClient;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.RowSet;
import hunt.database.base.Tuple;

import hunt.collection.List;


/**
 * Defines the client operations with a database server.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
interface SqlClient {

    /**
     * Execute a simple query.
     *
     * @param sql the query SQL
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    SqlClient query(string sql, RowSetHandler handler);

    /**
     * Execute a simple query.
     *
     * @param sql the query SQL
     * @param collector the collector
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    // <R> SqlClient query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Prepare and execute a query.
     *
     * @param sql the prepared query SQL
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    SqlClient preparedQuery(string sql, RowSetHandler handler);

    /**
     * Prepare and execute a query.
     *
     * @param sql the prepared query SQL
     * @param collector the collector
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    // <R> SqlClient preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Prepare and execute a query.
     *
     * @param sql the prepared query SQL
     * @param arguments the list of arguments
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    SqlClient preparedQuery(string sql, Tuple arguments, RowSetHandler handler);

    /**
     * Prepare and execute a query.
     *
     * @param sql the prepared query SQL
     * @param arguments the list of arguments
     * @param collector the collector
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    // <R> SqlClient preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Prepare and execute a createBatch.
     *
     * @param sql the prepared query SQL
     * @param batch the batch of tuples
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    SqlClient preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler);

    /**
     * Prepare and execute a createBatch.
     *
     * @param sql the prepared query SQL
     * @param batch the batch of tuples
     * @param collector the collector
     * @param handler the handler notified with the execution result
     * @return a reference to this, so the API can be used fluently
     */
    // <R> SqlClient preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Close the client and release the associated resources.
     */
    void close();

}
