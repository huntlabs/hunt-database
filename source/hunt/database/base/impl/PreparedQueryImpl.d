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

module hunt.database.base.impl.PreparedQueryImpl;

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.CursorImpl;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.QueryResultHandler;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.SqlResultBuilder;

import hunt.database.base.impl.command.CloseCursorCommand;
import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;
import hunt.database.base.impl.command.ExtendedQueryCommand;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Cursor;
import hunt.database.base.Exceptions;
import hunt.database.base.PreparedQuery;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.RowStream;
import hunt.database.base.Row;
import hunt.database.base.Tuple;

import hunt.collection.List;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.Object;

import core.atomic;
import std.array;
import std.variant;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PreparedQueryImpl : PreparedQuery {

    private DbConnection conn;
    private PreparedStatement ps;
    private shared bool closed = false;
    private Variant[string] _parameters;

    this(DbConnection conn, PreparedStatement ps) { 
        this.conn = conn;
        this.ps = ps;
    }

    void setParameter(string name, Variant value) {

    }

    PreparedQuery execute(RowSetHandler handler) {
        return execute(ArrayTuple.EMPTY, handler);
    }

    override
    PreparedQuery execute(Tuple args, RowSetHandler handler) {
        return execute!(RowSet, RowSetImpl, RowSet)(args, false, RowSetImpl.FACTORY, handler);
    }

    // <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> 
    private PreparedQuery execute(R1, R2, R3)(
            Tuple args, bool singleton,
            Function!(R1, R2) factory,
            // Collector<Row, ?, R1> collector,
            AsyncResultHandler!(R3) handler) {

        SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder!(R1, R2, R3)(factory, handler);
        return execute!(R1)(args, 
            0, "", false, singleton, b, 
            (CommandResponse!bool r) {  b.handle(r); }
        );
    }

    PreparedQuery execute(R)(Tuple args,
            int fetch,
            string cursorId,
            bool suspended,
            bool singleton,
            QueryResultHandler!(R) resultHandler,
            ResponseHandler!(bool) handler) {

        string msg = ps.prepare(cast(List!(Variant)) args);
        if (!msg.empty()) {
            version(HUNT_DB_DEBUG) warning(msg);
            handler(failedResponse!(bool)(new DatabaseException(msg)));
        } else {
            ExtendedQueryCommand!R cmd = new ExtendedQueryCommand!R(
                ps,
                args,
                fetch,
                cursorId,
                suspended,
                singleton,
                resultHandler);
            cmd.handler = handler;
            conn.schedule(cmd);
        }
   
        return this;
    }

    Cursor cursor() {
        return cursor(ArrayTuple.EMPTY);
    }

    // override
    Cursor cursor(Tuple args) {
        string msg = ps.prepare(cast(List!(Variant)) args);
        if (msg !is null) {
            throw new IllegalArgumentException(msg);
        }
        return new CursorImpl(this, args);
    }

    // override
    void close() {

        warning("do nothing");
        
        // close(ar -> {
        // });
    }

    PreparedQuery batch(List!(Tuple) argsList, RowSetHandler handler) {
        // return batch(argsList, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
        implementationMissing(false);
        return null;
    }

    // override
    // <R> PreparedQuery batch(List!(Tuple) argsList, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return batch(argsList, true, SqlResultImpl::new, collector, handler);
    // }

    // private <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> PreparedQuery batch(
    //     List!(Tuple) argsList,
    //     bool singleton,
    //     Function!(R1, R2) factory,
    //     Collector<Row, ?, R1> collector,
    //     Handler!(AsyncResult!(R3)) handler) {
    //     for  (Tuple args : argsList) {
    //         string msg = ps.prepare((List!(Object)) args);
    //         if (msg !is null) {
    //             handler.handle(Future.failedFuture(msg));
    //             return this;
    //         }
    //     }
    //     SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder<>(factory, handler);
    //     ExtendedBatchQueryCommand cmd = new ExtendedBatchQueryCommand<>(ps, argsList, singleton, collector, b);
    //     cmd.handler = b;
    //     conn.schedule(cmd);
    //     return this;
    // }

    // override
    // RowStream!(Row) createStream(int fetch, Tuple args) {
    //     return new RowStreamImpl(this, fetch, args);
    // }

    override
    void close(AsyncVoidHandler handler) {
        version(HUNT_DB_DEBUG) infof("closed: %s", closed);
        if(cas(&closed, false, true)) {
            CloseStatementCommand cmd = new CloseStatementCommand(ps);
            cmd.handler = (h) { 
                if(handler !is null) {
                    handler(h); 
                }
            };
            conn.schedule(cmd);
        } else if(handler !is null) {
            handler(failedResult!(Void)(new DatabaseException("Already closed")));
        }
    }

    void closeCursor(string cursorId, AsyncVoidHandler handler) {
        version(HUNT_DB_DEBUG) infof("cursorId: %s", cursorId);
        CloseCursorCommand cmd = new CloseCursorCommand(cursorId, ps);
        cmd.handler = (h) { if(handler !is null) handler(h); };
        conn.schedule(cmd);
    }
}
