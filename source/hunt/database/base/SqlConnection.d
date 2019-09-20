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

module hunt.database.base.SqlConnection;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import hunt.database.base.SqlClient;
import hunt.database.base.Transaction;
import hunt.database.base.Tuple;

import hunt.collection.List;
import hunt.concurrency.Future;

alias AsyncSqlConnectionHandler = AsyncResultHandler!SqlConnection;
alias SqlConnectionAsyncResult = AsyncResult!SqlConnection;


/**
 * A connection to database server.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
interface SqlConnection : SqlClient {

    /**
     * Set an handler called with connection errors.
     *
     * @param handler the handler
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnection exceptionHandler(ExceptionHandler handler);

    /**
     * Set an handler called when the connection is closed.
     *
     * @param handler the handler
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnection closeHandler(VoidHandler handler);

    /**
     * Begin a transaction and returns a {@link Transaction} for controlling and tracking
     * this transaction.
     * <p/>
     * When the connection is explicitely closed, any inflight transaction is rollbacked.
     *
     * @return the transaction instance
     */
    Transaction begin();

    /**
     * @return whether the connection uses SSL
     */
    bool isSSL();

    /**
     * Close the current connection after all the pending commands have been processed.
     */
    void close();

    // override
    // <R> SqlConnection preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    SqlConnection query(string sql, RowSetHandler handler);

    alias query = SqlClient.query;

    // override
    // <R> SqlConnection query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    /**
     * Create a prepared query.
     *
     * @param sql the sql
     * @param handler the handler notified with the prepared query asynchronously
     */
    SqlConnection prepare(string sql, PreparedQueryHandler handler);

    Future!PreparedQuery prepareAsync(string sql);

    PreparedQuery prepare(string sql);

    SqlConnection preparedQuery(string sql, RowSetHandler handler);

    override
    SqlConnection preparedQuery(string sql, Tuple arguments, RowSetHandler handler);

    // override
    // <R> SqlConnection preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);

    // override
    // SqlConnection preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler);

    // override
    // <R> SqlConnection preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler);


    /**
     * Return the given string suitably quoted to be used as an identifier in an SQL statement string.
     * Quotes are added only if necessary (i.e., if the string contains non-identifier characters or
     * would be case-folded). Embedded quotes are properly doubled.
     *
     * @param identifier input identifier
     * @return the escaped identifier
     * @throws SQLException if something goes wrong
     */
    string escapeIdentifier(string identifier);

    /**
     * Return the given string suitably quoted to be used as a string literal in an SQL statement
     * string. Embedded single-quotes and backslashes are properly doubled. Note that quote_literal
     * returns null on null input.
     *
     * @param literal input literal
     * @return the quoted literal
     * @throws SQLException if something goes wrong
     * 
     * See_Also:
     *    https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
     */
    string escapeLiteral(string literal);
}
