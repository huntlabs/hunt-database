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

module hunt.database.base.PreparedQuery;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Cursor;
import hunt.database.base.RowSet;
import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.Tuple;

import hunt.collection.List;
// import java.util.stream.Collector;


alias PreparedQueryHandler = AsyncResultHandler!(PreparedQuery);
alias PreparedQueryAsyncResult = AsyncResult!PreparedQuery;

/**
 * A prepared query.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
interface PreparedQuery {

    /**
     * Calls {@link #execute(Tuple, Handler)} with an empty tuple argument.
     */
    PreparedQuery execute(RowSetHandler handler);
    // {
    //     return execute(ArrayTuple.EMPTY, handler);
    // }

    /**
     * Calls {@link #execute(Tuple, Collector, Handler)} with an empty tuple argument.
     */
    // default <R> PreparedQuery execute(Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return execute(ArrayTuple.EMPTY, collector, handler);
    // }

    /**
     * Create a cursor with the provided {@code arguments}.
     *
     * @param args the list of arguments
     * @return the query
     */
    PreparedQuery execute(Tuple args, RowSetHandler handler);

    /**
     * Create a cursor with the provided {@code arguments}.
     *
     * @param args the list of arguments
     * @param collector the collector
     * @return the query
     */
    // <R> PreparedQuery execute(Tuple args, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * @return create a query cursor with a {@code fetch} size and empty arguments
     */
    Cursor cursor();
    // default Cursor cursor() {
    //     return cursor(ArrayTuple.EMPTY);
    // }

    /**
     * Create a cursor with the provided {@code arguments}.
     *
     * @param args the list of arguments
     * @return the query
     */
    Cursor cursor(Tuple args);

    /**
     * Execute the prepared query with a cursor and createStream the result. The createStream opens a cursor
     * with a {@code fetch} size to fetch the results.
     * <p/>
     * Note: this requires to be in a transaction, since cursors require it.
     *
     * @param fetch the cursor fetch size
     * @param args the prepared query arguments
     * @return the createStream
     */
    // RowStream!(Row) createStream(int fetch, Tuple args);

    /**
     * Execute a batch.
     *
     * @param argsList the list of tuple for the batch
     * @return the createBatch
     */
    PreparedQuery batch(List!(Tuple) argsList, RowSetHandler handler);

    /**
     * Execute a batch.
     *
     * @param argsList the list of tuple for the batch
     * @param collector the collector
     * @return the createBatch
     */
    // <R> PreparedQuery batch(List!(Tuple) argsList, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Close the prepared query and release its resources.
     */
    void close();

    /**
     * Like {@link #close()} but notifies the {@code completionHandler} when it's closed.
     */
    void close(AsyncVoidHandler completionHandler);

}
