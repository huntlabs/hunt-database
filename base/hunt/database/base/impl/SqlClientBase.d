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

module hunt.database.base.impl.SqlClientBase;

import hunt.database.base.impl.command.CommandScheduler;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;
import hunt.database.base.impl.command.ExtendedQueryCommand;
import hunt.database.base.impl.command.PrepareStatementCommand;
import hunt.database.base.impl.command.SimpleQueryCommand;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.SqlClient;
import hunt.database.base.Tuple;
import hunt.database.base.AsyncResult;

import hunt.net.AbstractConnection;

// import io.vertx.core.Future;
// import io.vertx.core.Handler;

// import hunt.collection.List;
// import java.util.function.Function;
// import java.util.stream.Collector;


/**
*/
abstract class SqlClientBase(C) : SqlClient, CommandScheduler if(is(C : SqlClient)) {

    override
    C query(string sql, RowSetHandler handler) {
        return query(sql, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
    }

    // override
    // <R> C query(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return query(sql, true, SqlResultImpl::new, collector, handler);
    // }

    // private <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> C query(
    //     string sql,
    //     boolean singleton,
    //     Function!(R1, R2) factory,
    //     Collector<Row, ?, R1> collector,
    //     Handler!(AsyncResult!(R3)) handler) {
    //     SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder<>(factory, handler);
    //     schedule(new SimpleQueryCommand<>(sql, singleton, collector, b), b);
    //     return (C) this;
    // }

    override
    C preparedQuery(string sql, Tuple arguments, RowSetHandler handler) {
        return preparedQuery(sql, arguments, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
    }

    // override
    // <R> C preparedQuery(string sql, Tuple arguments, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return preparedQuery(sql, arguments, true, SqlResultImpl::new, collector, handler);
    // }

    // private <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> C preparedQuery(
    //     string sql,
    //     Tuple arguments,
    //     boolean singleton,
    //     Function!(R1, R2) factory,
    //     Collector<Row, ?, R1> collector,
    //     Handler!(AsyncResult!(R3)) handler) {
    //     schedule(new PrepareStatementCommand(sql), cr -> {
    //         if (cr.succeeded()) {
    //             PreparedStatement ps = cr.result();
    //             string msg = ps.prepare((List!(Object)) arguments);
    //             if (msg !is null) {
    //                 handler.handle(Future.failedFuture(msg));
    //             } else {
    //                 SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder<>(factory, handler);
    //                 cr.scheduler.schedule(new ExtendedQueryCommand<>(ps, arguments, singleton, collector, b), b);
    //             }
    //         } else {
    //             handler.handle(Future.failedFuture(cr.cause()));
    //         }
    //     });
    //     return (C) this;
    // }

    // override
    // C preparedQuery(string sql, RowSetHandler handler) {
    //     return preparedQuery(sql, ArrayTuple.EMPTY, handler);
    // }

    // override
    // <R> C preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return preparedQuery(sql, ArrayTuple.EMPTY, collector, handler);
    // }

    // override
    // C preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler) {
    //     return preparedBatch(sql, batch, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
    // }

    // override
    // <R> C preparedBatch(string sql, List!(Tuple) batch, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return preparedBatch(sql, batch, true, SqlResultImpl::new, collector, handler);
    // }

    // private <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> C preparedBatch(
    //     string sql,
    //     List!(Tuple) batch,
    //     boolean singleton,
    //     Function!(R1, R2) factory,
    //     Collector<Row, ?, R1> collector,
    //     Handler!(AsyncResult!(R3)) handler) {
    //     schedule(new PrepareStatementCommand(sql), cr -> {
    //         if (cr.succeeded()) {
    //             PreparedStatement ps = cr.result();
    //             for  (Tuple args : batch) {
    //                 string msg = ps.prepare((List!(Object)) args);
    //                 if (msg !is null) {
    //                     handler.handle(Future.failedFuture(msg));
    //                     return;
    //                 }
    //             }
    //             SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder<>(factory, handler);
    //             cr.scheduler.schedule(new ExtendedBatchQueryCommand<>(
    //                 ps,
    //                 batch,
    //                 singleton,
    //                 collector,
    //                 b), b);
    //         } else {
    //             handler.handle(Future.failedFuture(cr.cause()));
    //         }
    //     });
    //     return (C) this;
    // }
}
