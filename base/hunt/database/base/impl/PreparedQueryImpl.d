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
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.PreparedStatement;


import hunt.database.base.impl.command.CloseCursorCommand;
import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;
import hunt.database.base.impl.command.ExtendedQueryCommand;
import hunt.database.base.Common;
import hunt.database.base.Cursor;
import hunt.database.base.PreparedQuery;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.RowStream;
import hunt.database.base.Row;
import hunt.database.base.Tuple;
// import io.vertx.core.*;

import hunt.collection.List;
import hunt.Exceptions;
// import java.util.concurrent.atomic.AtomicBoolean;
// import java.util.function.Function;
// import java.util.stream.Collector;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PreparedQueryImpl : PreparedQuery {

    private DbConnection conn;
    // private Context context;
    private PreparedStatement ps;
    // private AtomicBoolean closed = new AtomicBoolean();
    private shared bool closed = false;

    this(DbConnection conn, PreparedStatement ps) { // Context context, 
        this.conn = conn;
        // this.context = context;
        this.ps = ps;
    }

    PreparedQuery execute(RowSetHandler handler) {

        implementationMissing(false);
        return null;
    }

    override
    PreparedQuery execute(Tuple args, RowSetHandler handler) {
        // return execute(args, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
        implementationMissing(false);
        return null;
    }

    // PreparedQuery execute(R)(Tuple args, Handler!(AsyncResult!(SqlResult!(R))) handler) { // Collector<Row, ?, R> collector, 
    //     return execute(args, true, SqlResultImpl::new, collector, handler);
    // }

    // private <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> PreparedQuery execute(
    //     Tuple args,
    //     boolean singleton,
    //     Function!(R1, R2) factory,
    //     Collector<Row, ?, R1> collector,
    //     Handler!(AsyncResult!(R3)) handler) {
    //     SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder<>(factory, handler);
    //     return execute(args, 0, null, false, singleton, collector, b, b);
    // }

    // <A, R> PreparedQuery execute(Tuple args,
    //                                                          int fetch,
    //                                                          string cursorId,
    //                                                          boolean suspended,
    //                                                          boolean singleton,
    //                                                          Collector!(Row, A, R) collector,
    //                                                          QueryResultHandler!(R) resultHandler,
    //                                                          Handler!(AsyncResult!(Boolean)) handler) {
    //     if (context == Vertx.currentContext()) {
    //         string msg = ps.prepare((List!(Object)) args);
    //         if (msg !is null) {
    //             handler.handle(Future.failedFuture(msg));
    //         } else {
    //             ExtendedQueryCommand cmd = new ExtendedQueryCommand<>(
    //                 ps,
    //                 args,
    //                 fetch,
    //                 cursorId,
    //                 suspended,
    //                 singleton,
    //                 collector,
    //                 resultHandler);
    //             cmd.handler = handler;
    //             conn.schedule(cmd);
    //         }
    //     } else {
    //         context.runOnContext(v -> execute(args, fetch, cursorId, suspended, singleton, collector, resultHandler, handler));
    //     }
    //     return this;
    // }

    Cursor cursor() {
        return cursor(ArrayTuple.EMPTY);
    }

    // override
    Cursor cursor(Tuple args) {
        string msg = ps.prepare(cast(List!(Object)) args);
        if (msg !is null) {
            throw new IllegalArgumentException(msg);
        }
        return new CursorImpl(this, args);
    }

    // override
    void close() {
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
    //     boolean singleton,
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
    void close(VoidHandler completionHandler) {
        // if (closed.compareAndSet(false, true)) {
        //     CloseStatementCommand cmd = new CloseStatementCommand(ps);
        //     cmd.handler = completionHandler;
        //     conn.schedule(cmd);
        // } else {
        //     completionHandler.handle(Future.failedFuture("Already closed"));
        // }
        implementationMissing(false);
    }

    void closeCursor(string cursorId, VoidHandler handler) {
        CloseCursorCommand cmd = new CloseCursorCommand(cursorId, ps);
        // cmd.handler = handler;
        implementationMissing(false);
        conn.schedule(cmd);
    }
}
