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
module hunt.database.base.impl.TransactionImpl;

import hunt.database.base.impl.Connection;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.SqlClientBase;
import hunt.database.base.impl.SqlConnectionBase;
import hunt.database.base.impl.SqlResultBuilder;
import hunt.database.base.impl.TxStatus;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.QueryCommandBase;
import hunt.database.base.impl.command.SimpleQueryCommand;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import hunt.database.base.SqlClient;
import hunt.database.base.Transaction;

import hunt.concurrency.Future;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Object;

import std.string;
import std.container.dlist;

/**
 * 
 */
class TransactionImpl : SqlConnectionBase!(TransactionImpl), Transaction {

    private enum int ST_BEGIN = 0;
    private enum int ST_PENDING = 1;
    private enum int ST_PROCESSING = 2;
    private enum int ST_COMPLETED = 3;

    private AsyncVoidHandler disposeHandler;
    // private Deque<CommandBase<?>> pending = new ArrayDeque<>();
    private DList!(ICommand) pending;
    private AsyncVoidHandler failedHandler;
    private int status = ST_BEGIN;

    this(DbConnection conn, AsyncVoidHandler disposeHandler) { 
        super(conn); 
        this.disposeHandler = disposeHandler;
        doSchedule(doQuery("BEGIN", &afterBegin));
    }

    override Transaction prepare(string sql, PreparedQueryHandler handler) {
        return super.prepare(sql, handler);
    }
    alias prepare = SqlConnectionBase!(TransactionImpl).prepare;

    override TransactionImpl query(string sql, RowSetHandler handler) {
        return super.query(sql, handler);
    }

    // override Future!RowSet queryAsync(string sql) {
    //     return super.queryAsync(sql);
    // }

    // override RowSet query(string sql) {
    //     return super.query(sql);
    // }
    
    alias query = SqlClientBase!(TransactionImpl).query;

    private void doSchedule(ICommand cmd) {
        conn.schedule(cmd);
    }

    private void afterBegin(AsyncResult!RowSet ar) {
        synchronized (this) {
            if (ar.succeeded()) {
                status = ST_PENDING;
            } else {
                status = ST_COMPLETED;
            }
            checkPending();
        }
    }

    private bool isComplete(ICommand cmd) {
        IQueryCommand queryCmd = cast(IQueryCommand)cmd;
        if (queryCmd !is null) {
            string sql = queryCmd.sql().strip().toUpper();
            return sql == "COMMIT" || sql == "ROLLBACK";
        }
        return false;
    }


    private void checkPending() {
        synchronized (this) {
            doCheckPending();
        }
    }

    private void doCheckPending() {
        switch (status) {
            case ST_BEGIN:
                break;
            case ST_PENDING: {
                ICommand cmd = pollPending();
                if (cmd !is null) {
                    if (isComplete(cmd)) {
                        status = ST_COMPLETED;
                    } else {
                        wrap(cmd);
                        status = ST_PROCESSING;
                    }
                    doSchedule(cmd);
                }
                break;
            }
            case ST_PROCESSING:
                break;
            case ST_COMPLETED: {
                if (!pending.empty()) {
                    DatabaseException err = new DatabaseException("Transaction already completed");
                    ICommand cmd;
                    while ((cmd = pollPending()) !is null) {
                        cmd.fail(err);
                    }
                }
                break;
            }

            default:
                warning("unhandled status: %d", status);
                break;
        }
    }

    private ICommand pollPending() {
        if(pending.empty())
            return null;
        ICommand r = pending.front();
        pending.removeFront();
        return r;
    }

    // override
    // <R> void schedule(CommandBase!(R) cmd, Handler<? super CommandResponse!(R)> handler) {
    //     cmd.handler = cr -> {
    //         cr.scheduler = this;
    //         handler.handle(cr);
    //     };
    //     schedule(cmd);
    // }

    override void schedule(ICommand cmd) {
        synchronized (this) {
            pending.insertBack(cmd);
        }
        checkPending();
    }

    private void wrap(ICommand cmd) {
        auto rowSetCommand = cast(CommandBase!bool)cmd;
        if(rowSetCommand !is null) {
            wrap!(bool)(rowSetCommand);
            return;
        } 
        
        auto preparedStatementCommand = cast(CommandBase!PreparedStatement)cmd;
        if(preparedStatementCommand !is null) { 
            wrap!(PreparedStatement)(preparedStatementCommand);
            return;
        }

        version(HUNT_DB_DEBUG) trace(typeid(cast(Object)cmd));
        implementationMissing(false);
    }

    private void wrap(T)(CommandBase!T cmd) {
        ResponseHandler!T handler = cmd.handler;
        cmd.handler = (CommandResponse!T ar) {
            synchronized (this) {
                status = ST_PENDING;
                if (ar.txStatus() == TxStatus.FAILED) {
                    // We won't recover from this so rollback
                    ICommand c;
                    while ((c = pollPending()) !is null) {
                        c.fail(new DatabaseException("rollback exception"));
                    }
                    AsyncVoidHandler h = failedHandler;
                    if (h !is null) {
                        // context.runOnContext(h);
                        warning("running here");
                        h(null);
                    }
                    schedule(doQuery("ROLLBACK", (ar2) {
                        trace("running here");
                        disposeHandler(null);
                        handler(ar);
                    }));
                } else {
                    handler(ar);
                    checkPending();
                }
            }
        };
    }

    // override
    void commit() {
        commit(null);
    }

    void commit(AsyncVoidHandler handler) {
        version(HUNT_DB_DEBUG_MORE) tracef("status: %d", status);
        switch (status) {
            case ST_BEGIN:
            case ST_PENDING:
            case ST_PROCESSING:
                // version(HUNT_DB_DEBUG) trace("running here");
                schedule(doQuery("COMMIT", (ar) {
                    // version(HUNT_DB_DEBUG) trace("running here");
                    disposeHandler(null);
                    if (handler !is null) {
                        // version(HUNT_DB_DEBUG) trace("running here");
                        if (ar.succeeded()) {
                            handler(succeededResult(cast(Void)null));
                        } else {
                            version(HUNT_DB_DEBUG) warning(ar.cause());
                            handler(failedResult!Void(ar.cause()));
                        }
                    }
                }));
                break;
            case ST_COMPLETED:
                if (handler !is null) {
                    handler(failedResult!Void(new DatabaseException("Transaction already completed")));
                }
                break;

            default:
                break;
        }
    }

    // override
    void rollback() {
        rollback(null);
    }

    void rollback(AsyncVoidHandler handler) {
        // version(HUNT_DB_DEBUG) trace("running here");
        schedule(doQuery("ROLLBACK", (RowSetAsyncResult ar) {
            // version(HUNT_DB_DEBUG) trace("running here");
            disposeHandler(null);
            if (handler !is null) {
                handler(succeededResult(cast(Void)null));
            }
        }));
    }

    override
    void close() {
        rollback();
    }

    override
    Transaction abortHandler(AsyncVoidHandler handler) {
        failedHandler = handler;
        return this;
    }

    private ICommand doQuery(string sql, RowSetHandler handler) {
        auto b = new SqlResultBuilder!(RowSet, RowSetImpl, RowSet)(RowSetImpl.FACTORY, handler);
        auto cmd = new SimpleQueryCommand!(RowSet)(sql, false, b); 
        cmd.handler = (r) { b.handle(r); };
        return cmd;
    }
}
