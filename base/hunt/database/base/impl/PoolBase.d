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

module hunt.database.base.impl.PoolBase;

import hunt.database.base.impl.Connection;
import hunt.database.base.impl.ConnectionPool;
import hunt.database.base.impl.SqlClientBase;
import hunt.database.base.impl.SqlConnectionImpl;


import hunt.database.base.PoolOptions;
import hunt.database.base.Pool;
import hunt.database.base.SqlConnection;
import hunt.database.base.Transaction;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandScheduler;
import hunt.database.base.AsyncResult;

import hunt.Exceptions;

/**
 * Todo :
 *
 * - handle timeout when acquiring a connection
 * - for per statement pooling, have several physical connection and use the less busy one to avoid head of line blocking effect
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
abstract class PoolBase(P) : SqlClientBase!(P), Pool { //  extends PoolBase!(P)

//     private final Context context;
    private ConnectionPool pool;
//     private final boolean closeVertx;

    this(PoolOptions options) {
        int maxSize = options.getMaxSize();
        if (maxSize < 1) {
            throw new IllegalArgumentException("Pool max size must be > 0");
        }
        // this.context = context;
        this.pool = new ConnectionPool(&this.connect, maxSize, options.getMaxWaitQueueSize());
        // this.closeVertx = closeVertx;
    }

    abstract void connect(AsyncDbConnectionHandler completionHandler);

    override
    void getConnection(AsyncSqlConnectionHandler handler) {
        pool.acquire((DbConnectionAsyncResult ar) {
            if (ar.succeeded()) {
                DbConnection conn = ar.result();
                SqlConnection holder = wrap(conn);
                conn.initHolder(cast(DbConnection.Holder)holder);
                handler(succeededResult!SqlConnection(holder));
            } else {
                handler(failedResult!SqlConnection(ar.cause()));
            }
        });
    }

//     override
//     void begin(Handler!(AsyncResult!(Transaction)) handler) {
//         getConnection(ar -> {
//             if (ar.succeeded()) {
//                 SqlConnectionImpl conn = (SqlConnectionImpl) ar.result();
//                 Transaction tx = conn.begin(true);
//                 handler.handle(Future.succeededFuture(tx));
//             } else {
//                 handler.handle(Future.failedFuture(ar.cause()));
//             }
//         });
//     }

//     override
//     <R> void schedule(CommandBase!(R) cmd, Handler<? super CommandResponse!(R)> handler) {
//         Context current = Vertx.currentContext();
//         if (current == context) {
//             pool.acquire(new CommandWaiter() { // SHOULD BE IT !!!!!
//                 override
//                 protected void onSuccess(Connection conn) {
//                     cmd.handler = ar -> {
//                         ar.scheduler = new CommandScheduler() {
//                             override
//                             <R> void schedule(CommandBase!(R) cmd, Handler<? super CommandResponse!(R)> handler) {
//                                 cmd.handler = cr -> {
//                                     cr.scheduler = this;
//                                     handler.handle(cr);
//                                 };
//                                 conn.schedule(cmd);
//                             }
//                         };
//                         handler.handle(ar);
//                     };
//                     conn.schedule(cmd);
//                     conn.close(this);
//                 }
//                 override
//                 protected void onFailure(Throwable cause) {
//                     cmd.handler = handler;
//                     cmd.fail(cause);
//                 }
//             });
//         } else {
//             context.runOnContext(v -> schedule(cmd, handler));
//         }
//     }

//     private abstract class CommandWaiter implements Connection.Holder, Handler!(AsyncResult!(Connection)) {

//         protected abstract void onSuccess(Connection conn);

//         protected abstract void onFailure(Throwable cause);

//         override
//         void handleNotification(int processId, String channel, String payload) {
//             // What should we do ?
//         }

//         override
//         void handle(AsyncResult!(Connection) ar) {
//             if (ar.succeeded()) {
//                 Connection conn = ar.result();
//                 conn.init(this);
//                 onSuccess(conn);
//             } else {
//                 onFailure(ar.cause());
//             }
//         }

//         override
//         void handleClosed() {
//         }

//         override
//         void handleException(Throwable err) {
//         }
//     }

    protected abstract SqlConnection wrap(DbConnection conn);

    // private class ConnectionWaiter  { // Handler!(AsyncResult!(Connection))

    //     private AsyncSqlConnectionHandler handler;

    //     private ConnectionWaiter(Handler!(AsyncResult!(SqlConnection)) handler) {
    //         this.handler = handler;
    //     }

    //     override
    //     void handle(AsyncResult!(Connection) ar) {
    //         if (ar.succeeded()) {
    //             Connection conn = ar.result();
    //             SqlConnectionImpl holder = wrap(context, conn);
    //             conn.init(holder);
    //             handler.handle(Future.succeededFuture(holder));
    //         } else {
    //             handler.handle(Future.failedFuture(ar.cause()));
    //         }
    //     }
    // }

    protected void doClose() {
        pool.close();
        // if (closeVertx) {
        //     context.owner().close();
        // }
    }

    override
    void close() {
        doClose();
    }
}
