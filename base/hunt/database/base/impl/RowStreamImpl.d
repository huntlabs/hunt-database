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

module hunt.database.base.impl.RowStreamImpl;

import hunt.database.base.impl.PreparedQueryImpl;

import hunt.database.base.Cursor;
import hunt.database.base.Common;
import hunt.database.base.RowSet;
import hunt.database.base.RowStream;
import hunt.database.base.Row;
import hunt.database.base.Tuple;
import hunt.database.base.AsyncResult;

import hunt.Exceptions;

import std.conv;
import std.range;

class RowStreamImpl : RowStream!(Row) { // , RowSetHandler 

    private PreparedQueryImpl ps;
    private int _fetch;
    private Tuple params;

    private VoidHandler _endHandler;
    private EventHandler!(Row) rowHandler;
    private EventHandler!(Throwable) _exceptionHandler;
    private long demand;
    private bool emitting;
    private Cursor cursor;

    private InputRange!(Row) result;

    this(PreparedQueryImpl ps, int fetch, Tuple params) {
        this.ps = ps;
        this._fetch = fetch;
        this.params = params;
        this.demand = long.max;
    }

    override
    RowStream!(Row) exceptionHandler(ExceptionHandler handler) {
        _exceptionHandler = handler;
        return this;
    }

    override
    RowStream!(Row) handler(EventHandler!(Row) handler) {
        Cursor c;
        synchronized (this) {
            if (handler !is null) {
                if (cursor is null) {
                    rowHandler = handler;
                    c = cursor = ps.cursor(params);
                } else {
                    throw new UnsupportedOperationException("Handle me gracefully");
                }
            } else {
                if (cursor !is null) {
                    cursor = null;
                } else {
                    rowHandler = null;
                }
                return this;
            }
        }
        c.read(_fetch, this);
        return this;
    }

    override
    RowStream!(Row) pause() {
        demand = 0L;
        return this;
    }

    RowStream!(Row) fetch(long amount) {
        if (amount < 0L) {
            throw new IllegalArgumentException("Invalid fetch amount " ~ amount.to!string());
        }
        synchronized (this) {
            demand += amount;
            if (demand < 0L) {
                demand = long.max;
            }
            if (cursor is null) {
                return this;
            }
        }
        checkPending();
        return this;
    }

    override
    RowStream!(Row) resume() {
        return fetch(long.max);
    }

    override
    RowStream!(Row) endHandler(VoidHandler handler) {
        _endHandler = handler;
        return this;
    }

    // override
    void handle(AsyncResult!(RowSet) ar) {
        if (ar.failed()) {
            ExceptionHandler handler;
            synchronized (this) {
                cursor = null;
                handler = _exceptionHandler;
            }
            if (handler !is null) {
                handler(ar.cause());
            }
        } else {
            result = ar.result().iterator();
            checkPending();
        }
    }

    // override
    void close() {
        close(null);
    }

    // override
    void close(VoidHandler completionHandler) {
        Cursor c;
        synchronized (this) {
            if ((c = cursor) is null) {
                return;
            }
            cursor = null;
        }
        c.close(completionHandler);
    }

    private void checkPending() {
        synchronized (this) {
            if (emitting) {
                return;
            }
            emitting = true;
        }
        implementationMissing(false);
        // while (true) {
        //     synchronized (this) {
        //         if (demand == 0L || result is null) {
        //             emitting = false;
        //             break;
        //         }
        //         EventHandler!(Row) handler;
        //         Object event;
        //         if (result.hasNext()) {
        //             handler = rowHandler;
        //             event = result.next();
        //             if (demand != long.max) {
        //                 demand--;
        //             }
        //         } else {
        //             result = null;
        //             emitting = false;
        //             if (cursor.hasMore()) {
        //                 cursor.read(_fetch, this);
        //                 break;
        //             } else {
        //                 cursor = null;
        //                 handler = _endHandler;
        //                 event = null;
        //             }
        //         }
        //         if (handler !is null) {
        //             handler(event);
        //         }
        //     }
        // }
    }
}
