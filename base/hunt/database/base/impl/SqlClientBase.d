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

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.SqlResultBuilder;

import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandScheduler;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;
import hunt.database.base.impl.command.ExtendedQueryCommand;
import hunt.database.base.impl.command.PrepareStatementCommand;
import hunt.database.base.impl.command.SimpleQueryCommand;

import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.SqlClient;
import hunt.database.base.SqlResult;
import hunt.database.base.Tuple;
import hunt.database.base.AsyncResult;

import hunt.collection.List;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.net.AbstractConnection;

import std.variant;


/**
*/
abstract class SqlClientBase(C) : SqlClient, CommandScheduler  { // if(is(C : SqlClient))

    override
    C query(string sql, RowSetHandler handler) {
        return query!(RowSet, RowSetImpl, RowSet)(sql, false, RowSetImpl.FACTORY, handler); // RowSetImpl.COLLECTOR, 
    }

    private C query(R1, R2, R3)(
                string sql,
                bool singleton,
                Function!(R1, R2) factory,
                AsyncResultHandler!(R3) handler) {

        SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder!(R1, R2, R3)(factory, handler);
        schedule!(bool)(new SimpleQueryCommand!(R1)(sql, singleton, b), 
            (CommandResponse!bool r) {  b.handle(r); }
        );
        return cast(C) this;
    }

    override
    C preparedQuery(string sql, Tuple arguments, RowSetHandler handler) {
        return preparedQuery!(RowSet, RowSetImpl, RowSet)(sql, arguments, false, RowSetImpl.FACTORY, handler); // RowSetImpl.COLLECTOR, 
        // implementationMissing(false);
        // return cast(C) this;
    }

    // override
    // C preparedQuery(R)(string sql, Tuple arguments, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return preparedQuery(sql, arguments, true, SqlResultImpl::new, collector, handler);
    // }

    // <R1, R2 extends SqlResultBase!(R1, R2), R3 extends SqlResult!(R1)> 
    private C preparedQuery(R1, R2, R3)(
            string sql,
            Tuple arguments,
            bool singleton,
            Function!(R1, R2) factory,
            AsyncResultHandler!(R3) handler) {

        schedule!(PreparedStatement)(new PrepareStatementCommand(sql), 
            (CommandResponse!PreparedStatement cr) {
                if (cr.succeeded()) {
                    PreparedStatement ps = cr.result();
                    string msg = ps.prepare(cast(List!(Variant)) arguments);
                    if (msg !is null) {
                        version(HUNT_DEBUG) warning(msg);
                        handler(failedResult!(R3)(new Exception(msg)));
                    } else {
                        SqlResultBuilder!(R1, R2, R3) b = new SqlResultBuilder!(R1, R2, R3)(factory, handler);

                        CommandScheduler sc = cr.scheduler;
                        version(HUNT_DB_DEBUG) {
                            if(sc !is null) {
                                trace(typeid(cast(Object)sc));
                            }
                        }
                        SqlClientBase!(C) client = cast(SqlClientBase!(C))sc;
                        assert(client is this);

                        schedule!(bool)(new ExtendedQueryCommand!(R1)(ps, arguments, singleton, b), 
                            (CommandResponse!bool r) {  b.handle(r); }
                        ); 
                    }
                } else {
                    version(HUNT_DB_DEBUG) {
                        warning(cr.cause());
                    }
                    handler(failedResult!(R3)(cr.cause()));
                }
            }
        );

        return cast(C) this;
    }

    override
    C preparedQuery(string sql, RowSetHandler handler) {
        return preparedQuery(sql, ArrayTuple.EMPTY, handler);
    }

    // override
    // <R> C preparedQuery(string sql, Collector<Row, ?, R> collector, Handler!(AsyncResult!(SqlResult!(R))) handler) {
    //     return preparedQuery(sql, ArrayTuple.EMPTY, collector, handler);
    // }

    override
    C preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler) {
        // return preparedBatch(sql, batch, false, RowSetImpl.FACTORY, RowSetImpl.COLLECTOR, handler);
        implementationMissing(false);
        return null;
    }

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

    void schedule(R)(CommandBase!(R) cmd, ResponseHandler!R handler) {
        cmd.handler = (cr) {
            // Tx might be gone ???
            cr.scheduler = this;
            handler(cr);
        };
        schedule(cmd);
    }

    protected void schedule(ICommand cmd) {
        throw new NotImplementedException();
    }
}
