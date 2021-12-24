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

module hunt.database.base.impl.SqlResultBuilder;

import hunt.database.base.impl.QueryResultHandler;
import hunt.database.base.impl.RowDesc;

import hunt.database.base.SqlResult;
import hunt.database.base.AsyncResult;

import hunt.logging;
import hunt.Functions;

import std.variant;

/**
 * A query result handler for building a {@link SqlResult}.
 */
class SqlResultBuilder(T, R, L) : QueryResultHandler!(T) { // , Handler!(AsyncResult!(bool))

    // R extends SqlResultBase!(T, R)
    // L extends SqlResult!(T)

    private AsyncResultHandler!(L) handler;
    private Function!(T, R) factory;
    private R first;
    private bool suspended;

    this(Function!(T, R) factory, AsyncResultHandler!(L) handler) {
        this.factory = factory;
        this.handler = handler;
    }

    override
    void handleResult(int updatedCount, int size, RowDesc desc, T result) {
        R r = factory(result);
        r._updated = updatedCount;
        r._size = size;
        r._columnNames = desc !is null ? desc.columnNames() : null;
        handleResult(r);
    }

    private void handleResult(R result) {
        if (first is null) {
            first = result;
        } else {
            R h = first;
            while (h.next !is null) {
                h = h.next;
            }
            h.next = result;
        }
    }

    // override
    void handle(AsyncResult!(bool) res) {
        suspended = res.succeeded() && res.result();

        version(HUNT_DB_DEBUG) {
            tracef("succeeded: %s, result: %s", res.succeeded(), res.result());
        }

        if(handler !is null) {
            handler(res.map!(L)(first)); // AsyncResult!(RowSetImpl)
        }
    }

    void addProperty(string name, ref Variant value) {
        if(first !is null) {
            R r = first;
            while (r.next !is null) {
                r = r.next;
            }

            r.properties[name] = value;
        }
    }

    bool isSuspended() {
        return suspended;
    }
}
