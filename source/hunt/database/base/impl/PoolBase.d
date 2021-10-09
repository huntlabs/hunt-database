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
import hunt.database.base.impl.SqlClientBase;
import hunt.database.base.impl.SqlConnectionImpl;

import hunt.database.base.Exceptions;
import hunt.database.base.PoolOptions;
import hunt.database.base.Pool;
import hunt.database.base.SqlConnection;
import hunt.database.base.Transaction;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandScheduler;
import hunt.database.base.AsyncResult;

import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import core.time;

import std.conv;

import hunt.util.pool;
import hunt.Functions;

alias DbPoolOptions = hunt.database.base.PoolOptions.PoolOptions;
alias ObjectPoolOptions = hunt.util.pool.PoolOptions;

alias DbConnectionPool = ObjectPool!DbConnection;

/** 
 * 
 */
class DbConnectionFactory : ObjectFactory!(DbConnection) {

    private Consumer!(AsyncDbConnectionHandler) connector;
    private int counter = 0;

    override DbConnection makeObject() {
        counter++;
        FuturePromise!DbConnection promise = new FuturePromise!DbConnection("DbFactory " ~ counter.to!string());

        connector( (DbConnectionAsyncResult ar) {

            if (ar.succeeded()) {
                version(HUNT_DEBUG) infof("A new DB connection created");
                DbConnection conn = ar.result();
                promise.succeeded(conn);
            } else {
                version(HUNT_DEBUG) {
                    warning(ar.cause());
                }

                version(HUNT_DB_DEBUG) warning(ar);

                promise.failed(ar.cause());
            }
        });    

        DbConnection r = promise.get(5.seconds);

        return r;
    }

    override void destroyObject(DbConnection p) {
        version(HUNT_DB_DEBUG) {
            tracef("connection, id: %d, connected", p.getProcessId(), p.isConnected());
        }
        p.close(null);
    }

    override bool isValid(DbConnection p) {
        return p.isConnected();
    }
}

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

    private DbConnectionPool pool;
    private DbPoolOptions _options;

    this(DbPoolOptions options) {
        this._options = options;
        int maxSize = options.getMaxSize();
        if (maxSize < 1) {
            throw new IllegalArgumentException("Pool max size must be > 0");
        }
        // this.pool = new ConnectionPool(&this.connect, maxSize, options.getMaxWaitQueueSize());

        
        ObjectPoolOptions opOptions = new ObjectPoolOptions();
        opOptions.name = "DbPool";
        opOptions.size = options.getMaxSize();
        opOptions.maxWaitQueueSize = options.getMaxWaitQueueSize();

        DbConnectionFactory factory = new DbConnectionFactory();
        factory.connector = &connect;

        pool = new DbConnectionPool(factory, opOptions);
    }

    abstract void connect(AsyncDbConnectionHandler completionHandler);

    // override
    // void getConnection(AsyncSqlConnectionHandler handler) {
    //     pool.acquire((DbConnectionAsyncResult ar) {
    //         if (ar.succeeded()) {
    //             DbConnection conn = ar.result();
    //             SqlConnection holder = wrap(conn);
    //             conn.initHolder(cast(DbConnection.Holder)holder);
    //             handler(succeededResult!SqlConnection(holder));
    //         } else {
    //             handler(failedResult!SqlConnection(ar.cause()));
    //         }
    //     });
    // }


    int nextPromiseId() {
        import core.atomic;
        int c = atomicOp!("+=")(_promiseCounter, 1);
        return c;
    }
    private shared int _promiseCounter = 0;

    // Future!(SqlConnection) getConnectionAsync() {
    //     import std.conv;

    //     int id = nextPromiseId();
    //     version(HUNT_DEBUG) tracef("Try to get a DB connection for promise: %d", id);
    //     auto f = new FuturePromise!SqlConnection("acquire " ~ id.to!string());

    //     pool.acquire((DbConnectionAsyncResult ar) {
    //         if (ar.succeeded()) {
    //             DbConnection conn = ar.result();
    //             version(HUNT_DEBUG) tracef("Got a DB connection (id=%d) from promise (id=%s)", conn.getProcessId(), f.id);
                
    //             // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-01-17T16:41:20+08:00
    //             // 
    //             SqlConnection holder = wrap(conn);
    //             conn.initHolder(cast(DbConnection.Holder)holder);

    //             if(f.isDone()) {
    //                 debug {
    //                     warningf("The promise %s has been done. So the connection %d will be returned to the pool.", 
    //                         f.id(), conn.getProcessId());
    //                 }
    //                 conn.close(cast(DbConnection.Holder)holder);
    //             } else {
    //                 f.succeeded(holder);
    //             }
    //         } else {
    //             debug warningf("A promise failed, id=%s", f.id);
    //             f.failed(ar.cause());
    //         }
    //     });        

    //     return f;
    // }

    SqlConnection getConnection() {
        // pool.logStatus();
        size_t times = 0;
        SqlConnection conn;
        Duration dur = _options.awaittingTimeout();

        try {
            // https://github.com/eclipse-vertx/vertx-sql-client/issues/463
            version(HUNT_DEBUG) tracef("try to get a connection in %s", dur);
            DbConnection dbConn =  pool.borrow(dur);
            version(HUNT_DEBUG) tracef("Got a DB connection (id=%d)", dbConn.getProcessId());

            conn = wrap(dbConn);
            dbConn.initHolder(cast(DbConnection.Holder)conn);

            conn.closeHandler(() {
                version(HUNT_DEBUG) {
                    tracef("Returning DB connection (id=%d)", dbConn.getProcessId());
                }
                dbConn.initHolder(null);
                pool.returnObject(dbConn);
            });
                         

        } catch(Throwable ex) { 
            debug {
                warning(ex.msg);
                info(pool.toString());
            }

            version(HUNT_DB_DEBUG) {
                warning(ex);
            }
            // throw ex;
        }

        version(HUNT_DB_DEBUG) {
            if(conn is null) {
                throw new DatabaseException("Can't get a working DB connection.");
            }
        } else {
            while((conn is null) || (!conn.isConnected() && times < _options.retry())) {
                times++;
                warningf("Try to get a connection again, times: %d.", times);

                // Destory the broken connection
                if(conn !is null) {
                    conn.close();
                }

                // Future!(SqlConnection) f = getConnectionAsync();

                try {
                    DbConnection dbConn = pool.borrow(dur);
                    version(HUNT_DEBUG) tracef("Got a DB connection (id=%d)", dbConn.getProcessId());
                    conn = wrap(dbConn);
                    dbConn.initHolder(cast(DbConnection.Holder)conn); 
                } catch(Exception ex) {
                    warningf("Failed to get a connection after trying %d times", times);
                }
            }

            if(times > 0 && times == _options.retry()) {
                throw new DatabaseException("Can't get a working DB connection.");
            }
        }
        return conn;
    }

    Transaction begin() {
        SqlConnection conn = getConnection();
        return conn.begin(true);
    }

    // Future!Transaction beginAsync() {
    //     auto r = new FuturePromise!Transaction();
    //     getConnection( (SqlConnectionAsyncResult ar) {
    //         if (ar.succeeded()) {
    //             SqlConnection conn = ar.result();
    //             Transaction tx = conn.begin(true);
    //             r.succeeded(tx);
    //         } else {
    //             r.failed(ar.cause());
    //         }
    //     });
    //     return r;
    // }

    // override
    // void begin(AsyncTransactionHandler handler) {
    //     if(handler is null) return;
    //     getConnection( (SqlConnectionAsyncResult ar) {
    //         if (ar.succeeded()) {
    //             SqlConnection conn = ar.result();
    //             Transaction tx = conn.begin(true);
    //             handler(succeededResult(tx));
    //         } else {
    //             handler(failedResult!(Transaction)(ar.cause()));
    //         }
    //     });
    // }

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
    }

    override
    void close() {
        doClose();
    }

    int available() { return cast(int)pool.getNumActive(); }
    
    int waiters() { return cast(int)pool.getNumWaiters(); }

    int maxSize() { return cast(int)pool.size(); }
    
    int size() { return cast(int)pool.size(); }
}
