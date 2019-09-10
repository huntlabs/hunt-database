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

module hunt.database.base.impl.ConnectionPool;

import hunt.database.base.impl.Connection;

import hunt.database.base.AsyncResult;
import hunt.database.base.Exceptions;
import hunt.database.base.PoolOptions;
import hunt.database.base.impl.command.CommandBase;


import hunt.collection.ArrayList;
import hunt.concurrency.CompletableFuture;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Functions;

import std.algorithm;
import std.container;
import std.range;

alias DbConnectionPromise = CompletableFuture!(DbConnectionAsyncResult);

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class ConnectionPool {

    private Consumer!(AsyncDbConnectionHandler) connector;
    // private Consumer!(Handler!(AsyncResult!(Connection))) connector;
    private int maxSize;
    // private ArrayDeque!(Promise!(Connection)) waiters = new ArrayDeque<>();
    // private Set!(PooledConnection) all = new HashSet<>();
    // private ArrayDeque!(PooledConnection) available = new ArrayDeque<>();
    private DList!(DbConnectionPromise) waiters;
    private ArrayList!PooledConnection _all;
    private DList!PooledConnection _available;
    private int _size;
    private int maxWaitQueueSize;
    private bool checkInProgress;
    private bool closed;

    this(Consumer!(AsyncDbConnectionHandler) connector) {
        this(connector, PoolOptions.DEFAULT_MAX_SIZE, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
    }

    this(Consumer!(AsyncDbConnectionHandler) connector, int maxSize) {
        this(connector, maxSize, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
    }

    this(Consumer!(AsyncDbConnectionHandler) connector, int maxSize, int maxWaitQueueSize) {
        this.maxSize = maxSize;
        this.maxWaitQueueSize = maxWaitQueueSize;
        this.connector = connector;
    }


    private int waitersSize() {
        return cast(int)waiters[].walkLength();
    }

    int available() {
        return cast(int)_available[].walkLength();
    }

    int size() {
        return _size;
    }

    void acquire(AsyncDbConnectionHandler holder) {
        if (closed) {
            throw new IllegalStateException("Connection pool closed");
        }
        // Promise!(Connection) promise = Promise.promise();
        // promise.future().setHandler(holder);
        // waiters.add(promise);
        DbConnectionPromise promise = new DbConnectionPromise();
        promise.thenAccept((r) { if(holder !is null) holder(r);});
        waiters.insertBack(promise);
        check();
    }

    void close() {
        if (closed) {
            throw new IllegalStateException("Connection pool already closed");
        }
        closed = true;
        foreach (PooledConnection pooled ;_all) {
            pooled.close();
        }
        DbConnectionAsyncResult failure = failedResult!(DbConnection)(new Exception("Connection pool closed"));
        foreach (DbConnectionPromise pending ; waiters) {
            try {
                pending.complete(failure);
            } catch (Exception ignore) {
                version(HUNT_DEBUG) warning(ignore);
            }
        }
    }

    private class PooledConnection : DbConnection, DbConnection.Holder  {

        private DbConnection conn;
        private Holder holder;

        this(DbConnection conn) {
            this.conn = conn;
        }

        override
        bool isSsl() {
            return conn.isSsl();
        }

        override
        void schedule(ICommand cmd) {
            conn.schedule(cmd);
        }

        /**
         * Close the underlying connection
         */
        private void close() {
            conn.close(this);
        }

        override
        void initHolder(Holder holder) {
            if (this.holder !is null) {
                throw new IllegalStateException();
            }
            this.holder = holder;
        }

        override
        void close(Holder holder) {
            if (holder !is this.holder) {
                throw new IllegalStateException();
            }
            this.holder = null;
            release(this);
        }

        override
        void handleClosed() {
            if (_all.remove(cast(PooledConnection)this)) {
                _size--;
                if (holder is null) {
                    _available.linearRemoveElement(this);
                } else {
                    holder.handleClosed();
                }
                check();
            } else {
                throw new IllegalStateException();
            }
        }


        override
        void handleNotification(int processId, string channel, string payload) {
            if (holder !is null) {
                holder.handleNotification(processId, channel, payload);
            }
        }

        override
        void handleException(Throwable err) {
            if (holder !is null) {
                holder.handleException(err);
            }
        }

        override
        int getProcessId() {
            return conn.getProcessId();
        }

        override
        int getSecretKey() {
            return conn.getSecretKey();
        }
    }

    private void release(PooledConnection proxy) {
        if (_all.contains(proxy)) {
            _available.insertBack(proxy);
            check();
        }
    }

    private void check() {
        if (closed) {
            return;
        }
        if (!checkInProgress) {
            checkInProgress = true;
            try {
                while (waitersSize() > 0) {
                    if (available() > 0) {
                        PooledConnection proxy = _available.front(); _available.removeFront();
                        DbConnectionPromise waiter = waiters.front(); waiters.removeFront();
                        waiter.complete(succeededResult!(DbConnection)(proxy));
                    } else {
                        if (size < maxSize) {
                            DbConnectionPromise waiter = waiters.front(); waiters.removeFront();
                            _size++;
                            connector( (DbConnectionAsyncResult ar) {
                                if (ar.succeeded()) {
                                    DbConnection conn = ar.result();
                                    PooledConnection proxy = new PooledConnection(conn);
                                    _all.add(proxy);
                                    conn.initHolder(proxy);
                                    waiter.complete(succeededResult!(DbConnection)(proxy));
                                } else {
                                    _size--;
                                    waiter.completeExceptionally(ar.cause());
                                    check();
                                }
                            });
                        } else {
                            if (maxWaitQueueSize >= 0) {
                                int numInProgress = _size - _all.size();
                                int numToFail = cast(int)waiters[].walkLength() - (maxWaitQueueSize + numInProgress);
                                while (numToFail-- > 0) {
                                    DbConnectionPromise waiter = waiters.back(); waiters.removeBack();
                                    waiter.completeExceptionally(new NoStackTraceThrowable("Max waiter size reached"));
                                }
                            }
                            break;
                        }
                    }
                }
            } finally {
                checkInProgress = false;
            }
        }
    }
}
