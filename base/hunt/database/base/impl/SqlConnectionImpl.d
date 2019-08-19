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

import hunt.database.base.Common;
import hunt.database.base.SqlConnection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.SqlConnectionBase;
import hunt.database.base.impl.TransactionImpl;
import hunt.database.base.Transaction;

import hunt.logging.ConsoleLogger;
// import io.vertx.core.*;

import hunt.Object;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SqlConnectionImpl(C) : SqlConnectionBase!(C), SqlConnection //, Connection.Holder 
         { // if(is(C : SqlConnectionImpl))

    private ThrowableHandler exceptionHandler;
    private VoidHandler closeHandler;
    private TransactionImpl tx;

    this(AbstractConnection context, Connection conn) {
        super(context, conn);
    }

    override
    void handleClosed() {
        VoidHandler handler = closeHandler;
        if (handler !is null) {
            context.runOnContext(handler);
        }
    }

    // override
    void schedule(R)(CommandBase!(R) cmd, ResponseHandler!R handler) {
        cmd.handler = (cr) {
            // Tx might be gone ???
            cr.scheduler = this;
            handler(cr);
        };
        schedule(cmd);
    }

    protected void schedule(ICommand cmd) {
        if (context == Vertx.currentContext()) {
            if (tx !is null) {
                tx.schedule(cmd);
            } else {
                conn.schedule(cmd);
            }
        } else {
            context.runOnContext( (v) {
                schedule(cmd);
            });
        }
    }

    override
    void handleException(Throwable err) {
        EventHandler!(Throwable) handler = exceptionHandler;
        if (handler !is null) {
            context.runOnContext( (v) {
                handler(err);
            });
        } else {
            // err.printStackTrace();
            warning(err);
        }
    }

    override
    bool isSSL() {
        return conn.isSsl();
    }

    override
    C closeHandler(VoidHandler handler) {
        closeHandler = handler;
        return cast(C) this;
    }

    override
    C exceptionHandler(ThrowableHandler handler) {
        exceptionHandler = handler;
        return cast(C) this;
    }

    override
    Transaction begin() {
        return begin(false);
    }

    Transaction begin(bool closeOnEnd) {
        if (tx !is null) {
            throw new IllegalStateException();
        }
        tx = new TransactionImpl(context, conn, (v) {
            tx = null;
            if (closeOnEnd) {
                close();
            }
        });
        return tx;
    }

    abstract void handleNotification(int processId, string channel, string payload);

    override
    void close() {
        conn.close();
        // if (context == Vertx.currentContext()) {
        //     if (tx !is null) {
        //         tx.rollback(ar -> conn.close(this));
        //         tx = null;
        //     } else {
        //         conn.close(this);
        //     }
        // } else {
        //     context.runOnContext(v -> close());
        // }
    }
}