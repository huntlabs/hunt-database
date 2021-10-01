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

// import hunt.database.base.impl.Connection;

// import hunt.database.base.AsyncResult;
// import hunt.database.base.Exceptions;
// import hunt.database.base.PoolOptions;
// import hunt.database.base.impl.command.CommandBase;

// import hunt.collection.ArrayList;
// import hunt.concurrency.FuturePromise;
// import hunt.Exceptions;
// import hunt.logging.ConsoleLogger;
// import hunt.Functions;

// import core.atomic;
// import core.thread;

// import std.algorithm;
// import std.container;
// import std.format;
// import std.range;

// alias DbConnectionPromise = FuturePromise!(DbConnectionAsyncResult);

// /**
//  * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
//  */
// class ConnectionPool {

//     private Consumer!(AsyncDbConnectionHandler) connector;
//     // private Consumer!(Handler!(AsyncResult!(Connection))) connector;
//     private int _maxSize;
//     // private ArrayDeque!(Promise!(Connection)) _waiters = new ArrayDeque<>();
//     // private Set!(PooledConnection) all = new HashSet<>();
//     // private ArrayDeque!(PooledConnection) available = new ArrayDeque<>();
//     private DList!(FuturePromise!(DbConnectionAsyncResult)) _waiters;
//     private ArrayList!PooledConnection _all;
//     private DList!PooledConnection _available;
//     private shared int _size;
//     private int _maxWaitQueueSize;
//     private shared bool _checkInProgress;
//     private shared bool _closed;

//     this(Consumer!(AsyncDbConnectionHandler) connector) {
//         this(connector, PoolOptions.DEFAULT_MAX_SIZE, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
//     }

//     this(Consumer!(AsyncDbConnectionHandler) connector, int maxSize) {
//         this(connector, maxSize, PoolOptions.DEFAULT_MAX_WAIT_QUEUE_SIZE);
//     }

//     this(Consumer!(AsyncDbConnectionHandler) connector, int maxSize, int maxWaitQueueSize) {
//         version(HUNT_DEBUG) infof("Database pool: maxSize=%d, maxWaitQueueSize=%d", maxSize, maxWaitQueueSize);
//         this._maxSize = maxSize;
//         this._maxWaitQueueSize = maxWaitQueueSize;
//         this.connector = connector;
//         _all = new ArrayList!PooledConnection();
//     }

//     int waitersSize() {
//         return cast(int)_waiters[].walkLength();
//     }

//     int available() {
//         return cast(int)_available[].walkLength();
//     }

//     int maxSize() {
//         return _maxSize;
//     }

//     int size() {
//         return _size;
//     }

//     void acquire(AsyncDbConnectionHandler holder) {
//         if (_closed) {
//             throw new IllegalStateException("Connection pool closed");
//         }
        
//         import std.conv;
//         _waiterCount++;
//         string waiterName = "ConnectWaiter " ~ _waiterCount.to!string();

//         // version(HUNT_DEBUG) 
//         {
//             tracef("Try to acquire a DB connection for %s... size: %d/%d, available: %d, waiters: %d", 
//                 waiterName, _size, _maxSize, available(), waitersSize());
//         }

//         // Promise!(Connection) promise = Promise.promise();
//         // promise.future().setHandler(holder);
//         // _waiters.add(promise);

//         auto promise = new FuturePromise!(DbConnectionAsyncResult)(waiterName);
//         promise.then((r) { 
//             // version(HUNT_DEBUG) {
//                 infof("Acquired a DB connection %d for %s. size: %d/%d, available: %d, waiters: %d",
//                     r.result.getProcessId(), waiterName, _size, _maxSize, available(), waitersSize());
//             // }

//             if(holder !is null) holder(r);
//         });
        
//         // synchronized (this) {
//         //     warning("ddddddddddddd");
//         //     _waiters.insertBack(promise);
//         // }

//         insertWaiter(promise);

//         check();
//         warning("eeeeeeee: " ~ waiterName);
//     }

//     private int _waiterCount = 0;

//     void close() {
//         version(HUNT_DB_DEBUG) info("Closing...", _closed);
//         if (!cas(&_closed, false, true)) {
//             throw new IllegalStateException("Connection pool already closed");
//         }

//         foreach (PooledConnection pooled ;_all) {
//             pooled.close();
//         }

//         DbConnectionAsyncResult failure = failedResult!(DbConnection)(new Exception("Connection pool closed"));
//         foreach (FuturePromise!(DbConnectionAsyncResult) pending ; _waiters) {
//             try {
//                 pending.succeeded(failure);
//             } catch (Exception ignore) {
//                 version(HUNT_DEBUG) warning(ignore);
//             }
//         }
//     }

//     private class PooledConnection : DbConnection, DbConnection.Holder  {

//         private DbConnection conn;
//         private Holder holder;

//         this(DbConnection conn) {
//             this.conn = conn;
//         }

//         override bool isSsl() {
//             return conn.isSsl();
//         }

//         override bool isConnected() {
//             return conn.isConnected();
//         }

//         override
//         void schedule(ICommand cmd) {
//             conn.schedule(cmd);
//         }

//         /**
//          * Close the underlying connection
//          */
//         private void close() {
//             version(HUNT_DB_DEBUG) info("closing pooled connection....");
//             conn.close(this);
//         }

//         override
//         void initHolder(Holder holder) {
//             if (this.holder !is null) {
//                 throw new IllegalStateException("Illegal state");
//             }
//             this.holder = holder;
//         }

//         override
//         void close(Holder holder) {
//             if (holder !is this.holder) {
//                 throw new IllegalStateException("Illegal state");
//             }
//             this.holder = null;
//             release(this);
//         }

//         override
//         void handleClosed() {
//             synchronized (this) {
//                 if (_all.remove(this)) {
//                     atomicOp!("-=")(_size, 1); // --;
//                     if(_size<0) _size = 0;

//                     if (holder is null) {
//                         _available.linearRemoveElement(this);
//                     } else {
//                         holder.handleClosed();
//                     }
//                     check();
//                 } else {
//                     throw new IllegalStateException(format("Can't close connection, processId=%s", getProcessId()));
//                 }
                
//                 version(HUNT_DEBUG) 
//                 {
//                     tracef("DB connection %d closed.", getProcessId());
//                     infof("pool status, size: %d/%d, available: %d, waiters: %d, threads: %d",
//                         _size, _maxSize, available(), waitersSize(), Thread.getAll().length);
//                 }
//             }
//         }

//         override
//         void handleNotification(int processId, string channel, string payload) {
//             if (holder !is null) {
//                 holder.handleNotification(processId, channel, payload);
//             }
//         }

//         override
//         void handleException(Throwable err) {
//             if (holder !is null) {
//                 holder.handleException(err);
//             }
//         }

//         override
//         int getProcessId() {
//             return conn.getProcessId();
//         }

//         override
//         int getSecretKey() {
//             return conn.getSecretKey();
//         }
//     }

//     private void release(PooledConnection proxy) {
//         version(HUNT_DB_DEBUG) trace("Try to release a DB connection.");
//         synchronized (this) {
//             if (_all.contains(proxy)) {

//                 if(proxy.isConnected()) {
//                     _available.insertBack(proxy);
//                     version(HUNT_DEBUG) {
//                         tracef("The DB connection %d returned to the pool.", proxy.getProcessId());
//                         infof("pool status, size: %d/%d, available: %d, waiters: %d, threads: %d",
//                             _size, _maxSize, available(), waitersSize(), Thread.getAll().length);
//                     }
//                 } else {                
//                     warningf("For some reasons, a DB connection %d is closed, so drop it now.", proxy.getProcessId());
//                 }
//                 check();
//             } else {
//                 warningf("Releasing a untraced connection %d!", proxy.getProcessId());
//             }
//         }
//     }

//     private void check() {
//         if (_closed) {
//             version(HUNT_DEBUG) warning("pool closed!");
//             return;
//         }

//         if(!cas(&_checkInProgress, false, true)) {
//             version(HUNT_DEBUG) warning("check in progress...");
//             return;
//         }

//         scope(exit) {
//             _checkInProgress = false;
//             version(HUNT_DB_DEBUG_MORE) tracef("pool size=%d/%d", _size, _maxSize);
//         }

//         // synchronized (this) {
//             try {
//                 doCheck();
//             } catch(Exception ex) {
//                 warning(ex);
//             }
//         // }
//     }

//     void logStatus() {
//         infof("pool status, size: %d/%d, available: %d, waiters: %d, threads: %d",
//             _size, _maxSize, available(), waitersSize(), Thread.getAll().length);
//     }

//     private void insertWaiter(FuturePromise!(DbConnectionAsyncResult) waiter) {
//         synchronized (this) {
//             _waiters.insertBack(waiter);
//         }
//         info("okkkkkkk");
//     }

//     private FuturePromise!(DbConnectionAsyncResult) popWaiter() {
//         FuturePromise!(DbConnectionAsyncResult) waiter;
//         synchronized (this) {
//             warning("vvvvvvvvvv");
//             waiter = _waiters.front(); 
//             _waiters.removeFront();
//         }
//         info("ttttttttttttt");    
//         return waiter;    
//     }

//     private void doCheck() {
//         // while (waitersSize() > 0) 
//         while(!_waiters.empty())
//         {
//             if (available() > 0) {
//                 FuturePromise!(DbConnectionAsyncResult) waiter = popWaiter(); 
//                 PooledConnection proxy = _available.front(); _available.removeFront();
//                 waiter.succeeded(succeededResult!(DbConnection)(proxy));
//             } else {
//                 if (_size < _maxSize) {
//                     // _size++;
//                     atomicOp!("+=")(_size, 1);

//                     version(HUNT_DEBUG) infof("Creating a new DB connection. total: %d", _size);
//                     FuturePromise!(DbConnectionAsyncResult) waiter = popWaiter(); 

//                     connector( (DbConnectionAsyncResult ar) {

//                         if (ar.succeeded()) {
//                             version(HUNT_DEBUG) infof("A new DB connection created. total: %d", _size);
//                             DbConnection conn = ar.result();
//                             PooledConnection proxy = new PooledConnection(conn);
//                             _all.add(proxy);
//                             conn.initHolder(proxy);
//                             waiter.succeeded(succeededResult!(DbConnection)(proxy));
//                         } else {
//                             // _size--;
//                             atomicOp!("-=")(_size, 1);
//                             version(HUNT_DEBUG) warning(ar.cause());
//                             waiter.failed(ar.cause());
//                             check();
//                         }
//                     });

//                     info("connector connector connector");
//                 } else {
//                     version(HUNT_DEBUG) {
//                         // warningf("waiters: %d / %d", waitersSize(), _maxWaitQueueSize);
//                         infof("pool status, size: %d/%d, available: %d, waiters: %d, threads: %d",
//                             _size, _maxSize, available(), waitersSize(), Thread.getAll().length);
//                     }

//                     if (_maxWaitQueueSize >= 0) {
//                         int numInProgress = _size - _all.size();
//                         int numToFail = waitersSize() - (_maxWaitQueueSize + numInProgress);
//                         while (numToFail-- > 0) {
//                             FuturePromise!(DbConnectionAsyncResult) waiter = _waiters.back(); _waiters.removeBack();
//                             waiter.failed(new NoStackTraceThrowable("Max waiter size reached"));
//                         }
//                     }
//                     break;
//                 }
//             }
//         }
//     }
// }
