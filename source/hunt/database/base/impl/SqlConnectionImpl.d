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

module hunt.database.base.impl.SqlConnectionImpl;

import hunt.database.base.impl.Connection;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.SqlConnection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.SqlConnectionBase;
import hunt.database.base.impl.TransactionImpl;
import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import hunt.database.base.Transaction;
import hunt.database.base.Tuple;

import hunt.concurrency.Future;
import hunt.Exceptions;
import hunt.logging;
import hunt.net.AbstractConnection;
import hunt.Object;

import hunt.collection.List;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SqlConnectionImpl(C) : SqlConnectionBase!(C), SqlConnection, DbConnection.Holder //, 
{ // if(is(C : SqlConnectionImpl))

    private ExceptionHandler _exceptionHandler;
    private VoidHandler _closeHandler;
    private TransactionImpl tx;
    private bool _isClosed = false;

    this(DbConnection conn) {
        super(conn);
    }

    override C query(string sql, RowSetHandler handler) {
        return super.query(sql, handler);
    }

    override C prepare(string sql, PreparedQueryHandler handler) {
        return super.prepare(sql, handler);
    }

    override Future!PreparedQuery prepareAsync(string sql) {
        return super.prepareAsync(sql);
    }

    override PreparedQuery prepare(string sql) {
        return super.prepare(sql);
    }

    override C preparedQuery(string sql, RowSetHandler handler) {
        return super.preparedQuery(sql, handler);
    }

    override C preparedQuery(string sql, Tuple arguments, RowSetHandler handler) {
        return super.preparedQuery(sql, arguments, handler);
    }

    // override C preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler) {
    //     return super.preparedBatch(sql, batch, handler);
    // }

    // override protected AbstractNamedQueryDesc getNamedQueryDesc(string sql) {
    //     return super.getNamedQueryDesc(sql);
    // }

    // override Future!(NamedQuery) prepareNamedQueryAsync(string sql) {
    //     return super.prepareNamedQueryAsync(sql);
    // }

    // override NamedQuery prepareNamedQuery(string sql) {
    //     return super.prepareNamedQuery(sql);
    // }

    /** 
     * Handle on connection closing
     * Params:
     *   conn = 
     */
    void handleClosing() {
        version(HUNT_DB_DEBUG) { 
            tracef("The db connection %d closing.", conn.getProcessId());
        }
        // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-10-22T11:37:35+08:00
        // Not thread-safe

        // _isClosed = true;

        // Make sure that the binded transaction is completed.
        if (tx !is null && tx.status() != ST_COMPLETED) {
            warningf("A transaction is forced to rollback on connection (id=%d)", conn.getProcessId());
            tx.rollback();
        }        
    }

    /** 
     * Handle on connection closed
     */
    void handleClosed() {
        if(_isClosed) {
            version(HUNT_DEBUG) { 
                warningf("The db connection %d has been closed already.", conn.getProcessId());
            }
            return;
        }
        _isClosed = true;

        version(HUNT_DB_DEBUG) { 
            warningf("The db connection %d closed.", conn.getProcessId());
        }

        VoidHandler handler = _closeHandler;
        if (handler !is null) {
            version (HUNT_DB_DEBUG) {
                infof("Closing a SQL connection %d with handler...", conn.getProcessId());
            }
            handler();
        }
    }

    // override
    // void schedule(R)(CommandBase!(R) cmd, ResponseHandler!R handler) {
    //     cmd.handler = (cr) {
    //         // Tx might be gone ???
    //         cr.scheduler = this;
    //         handler(cr);
    //     };
    //     schedule(cmd);
    // }

    override void schedule(ICommand cmd) {
        if (tx !is null) {
            tx.schedule(cmd);
        } else {
            conn.schedule(cmd);
        }
    }

    void handleException(Throwable err) {
        EventHandler!(Throwable) handler = _exceptionHandler;
        if (handler !is null) {
            handler(err);
        } else {
            version (HUNT_DB_DEBUG_MORE) {
                warning(err);
            } else {
                warning(err.msg);
            }
        }
    }

    override bool isSSL() {
        return conn.isSsl();
    }

    override bool isConnected() {
        return conn.isConnected();
    }

    override C closeHandler(VoidHandler handler) {
        _closeHandler = handler;
        import hunt.Functions;
        
        
        return cast(C) this;
    }

    override C exceptionHandler(ExceptionHandler handler) {
        _exceptionHandler = handler;
        return cast(C) this;
    }

    override Transaction begin() {
        return begin(false);
    }

    Transaction begin(bool closeOnEnd) {
        if (tx !is null) {
            throw new IllegalStateException();
        }
        tx = new TransactionImpl(conn, (v) {
            tx = null;
            if (closeOnEnd) {
                close();
            }
        });
        return tx;
    }

    abstract void handleNotification(int processId, string channel, string payload);

    override void close() {
        version (HUNT_DB_DEBUG)
            infof("Closing a SQL connection %d...", conn.getProcessId());

        if(_isClosed) {
            warningf("The connection %d has been closed already.", conn.getProcessId());
            return;
        }

        handleClosing();

        VoidHandler handler = _closeHandler;
        if(handler !is null) {
            version (HUNT_DB_DEBUG) {
                infof("Closing a SQL connection %d with handler...", conn.getProcessId());
            }
            handler();
        } else {
            version (HUNT_DB_DEBUG)
                infof("Closing a DB connection in SQL connection %d...", conn.getProcessId());
            conn.close();

            // if (tx !is null) {
            //     tx.rollback((ar) { conn.close(this); });
            //     tx = null;
            // } else {
            //     conn.close(this);
            // }
        }
    }
}
