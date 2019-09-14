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
module hunt.database.base.Transaction;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import hunt.database.base.SqlClient;

import hunt.collection.List;

/**
 * A transaction that allows to control the transaction and receive events.
 */
interface Transaction : SqlClient {

    /**
     * Create a prepared query.
     *
     * @param sql the sql
     * @param handler the handler notified with the prepared query asynchronously
     */
    Transaction prepare(string sql, PreparedQueryHandler handler);

    /**
     * Commit the current transaction.
     */
    void commit();

    /**
     * Like {@link #commit} with an handler to be notified when the transaction commit has completed
     */
    void commit(AsyncVoidHandler handler);

    /**
     * Rollback the current transaction.
     */
    void rollback();

    /**
     * Like {@link #rollback} with an handler to be notified when the transaction rollback has completed
     */
    void rollback(AsyncVoidHandler handler);

    /**
     * Set an handler to be called when the transaction is aborted.
     *
     * @param handler the handler
     */
    Transaction abortHandler(AsyncVoidHandler handler);

    Transaction query(string sql, RowSetHandler handler);

    // override
    // <R> Transaction query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // Transaction preparedQuery(string sql, RowSetHandler handler);

    // override
    // <R> Transaction preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // Transaction preparedQuery(string sql, Tuple arguments, RowSetHandler handler);

    // override
    // <R> Transaction preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // Transaction preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler);

    // override
    // <R> Transaction preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Rollback the transaction and release the associated resources.
     */
    void close();
}
