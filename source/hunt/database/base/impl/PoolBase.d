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
import hunt.Functions;
import hunt.logging;
import hunt.util.pool;

import core.atomic;
import core.time;

import std.conv;


alias DbPoolOptions = hunt.database.base.PoolOptions.PoolOptions;
alias ObjectPoolOptions = hunt.util.pool.PoolOptions;

alias DbConnectionPool = ObjectPool!DbConnection;

/** 
 * 
 */
class DbConnectionFactory : ObjectFactory!(DbConnection) {

    private Consumer!(AsyncDbConnectionHandler) connector;
    private shared int counter = 0;
    private DbPoolOptions _options;

    this(DbPoolOptions options) {
        _options = options;
    }

    override DbConnection makeObject() {
        int c = atomicOp!("+=")(counter, 1);
        string name = "DbFactory-" ~ c.to!string();
        version(HUNT_DEBUG) {
            tracef("Making a DB connection for %s", name);
        }

        FuturePromise!DbConnection promise = new FuturePromise!DbConnection(name);

        connector( (DbConnectionAsyncResult ar) {

            if (ar.succeeded()) {
                DbConnection conn = ar.result();
                version(HUNT_DEBUG) {
                    infof("A new DB connection %d created", conn.getProcessId());
                }
                promise.succeeded(conn);
            } else {
                version(HUNT_DEBUG) {
                    warning(ar.cause());
                }

                version(HUNT_DB_DEBUG) warning(ar);

                promise.failed(ar.cause());
            }
        });    

        DbConnection r = promise.get(_options.awaittingTimeout);

        version(HUNT_DEBUG) {
            infof("DB connection making finished for %s", name);
        }

        return r;
    }

    override void destroyObject(DbConnection p) {
        if(p is null) {
            warning("The connection is null");
            return;
        }
        version(HUNT_DB_DEBUG) {
            tracef("Connection [%d] disconnected: %s", p.getProcessId(), p.isConnected());
        }
        p.close();
    }

    override bool isValid(DbConnection p) {
        if(p is null) {
            return false;
        } else {
            return p.isConnected();
        }
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
    private shared int _promiseCounter = 0;

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

        DbConnectionFactory factory = new DbConnectionFactory(options);
        factory.connector = &connect;

        pool = new DbConnectionPool(factory, opOptions);
    }

    abstract void connect(AsyncDbConnectionHandler completionHandler);


    int nextPromiseId() {
        import core.atomic;
        int c = atomicOp!("+=")(_promiseCounter, 1);
        return c;
    }

    SqlConnection getConnection() {
        // pool.logStatus();
        size_t times = 0;
        Duration dur = _options.awaittingTimeout();
        SqlConnection conn = tryToBorrowConnection(dur);

        version(HUNT_DB_DEBUG) {
            if(conn is null) {
                throw new DatabaseException("Can't get a valid DB connection.");
            }
        } else {
            while(times < _options.retry() && ((conn is null) || !conn.isConnected())) {
                times++;
                warningf("Try to get a connection again, times: %d.", times);

                // Destory the broken connection
                if(conn !is null) {
                    conn.close();
                }

                conn = tryToBorrowConnection(dur);
            }

            if(times > 0 && times == _options.retry()) {
                throw new DatabaseException("Can't get a working DB connection.");
            }
        }
        return conn;
    }

    private SqlConnection tryToBorrowConnection(Duration dur) {
        SqlConnection conn = null;

        try {
            // https://github.com/eclipse-vertx/vertx-sql-client/issues/463
            version(HUNT_DB_DEBUG) tracef("try to get a connection in %s", dur);
            DbConnection dbConn =  pool.borrow(dur);
            version(HUNT_DB_DEBUG) tracef("Got a DB connection (id=%d)", dbConn.getProcessId());

            conn = wrap(dbConn);
            dbConn.initHolder(cast(DbConnection.Holder)conn);

            conn.closeHandler(() {
                version(HUNT_DB_DEBUG) {
                    tracef("Returning a DB connection (id=%d), %s", 
                        dbConn.getProcessId(), (cast(Object)dbConn).toString());
                }
                dbConn.initHolder(null);
                // The borrowed object must be returned to the pool
                pool.returnObject(dbConn);

                // if(dbConn.isConnected()) {
                //     pool.returnObject(dbConn);
                // } else {
                //     warningf("Dropped a closed db connection %s", (cast(Object)dbConn).toString());
                // }
            });
                         

        } catch(Throwable ex) { 
            debug {
                warning(ex.msg);
                infof("Failed to borrow. %s", pool.toString());
            }

            version(HUNT_DB_DEBUG) {
                warning(ex);
            }
        }

        return conn;
    }

    Transaction begin() {
        SqlConnection conn = getConnection();
        return conn.begin(true);
    }


    protected abstract SqlConnection wrap(DbConnection conn);

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

    override string toString() {
        return pool.toString();
    }
}
