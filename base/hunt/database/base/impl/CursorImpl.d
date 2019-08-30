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

module hunt.database.base.impl.CursorImpl;

import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.SqlResultBuilder;
import hunt.database.base.impl.command.CommandResponse;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Cursor;
import hunt.database.base.RowSet;
import hunt.database.base.Tuple;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Object;

import std.range;
import std.uuid;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class CursorImpl : Cursor {

    private PreparedQueryImpl ps;
    private Tuple params;

    private string id;
    private bool closed;
    private SqlResultBuilder!(RowSet, RowSetImpl, RowSet) result;

    this(PreparedQueryImpl ps, Tuple params) {
        this.ps = ps;
        this.params = params;
    }

    override
    bool hasMore() {
        if (result is null) {
            throw new IllegalStateException("No current cursor read");
        }
        return result.isSuspended();
    }

    override
    void read(int count, RowSetHandler handler) {
        if (id.empty) {
            id = randomUUID().toString();
            result = new SqlResultBuilder!(RowSet, RowSetImpl, RowSet)(RowSetImpl.FACTORY, handler);
            ps.execute!(RowSet)(params, count, id, false, false, result, 
                (CommandResponse!bool r) {  result.handle(r); }
            );
        } else if (result.isSuspended()) {
            result = new SqlResultBuilder!(RowSet, RowSetImpl, RowSet)(RowSetImpl.FACTORY, handler);
            ps.execute!(RowSet)(params, count, id, true, false, result, 
                (CommandResponse!bool r) {  result.handle(r); }
            );
        } else {
            throw new IllegalStateException();
        }
    }

    override
    void close(AsyncVoidHandler completionHandler) {
        if (!closed) {
            closed = true;
            version(HUNT_DB_DEBUG_MORE) infof("id: %s", id);
            if (id.empty) { 
                if(completionHandler !is null)
                    completionHandler(succeededResult!(Object)(null)); // Future.succeededFuture()
            } else {
                string id = this.id;
                this.id = null;
                result = null;
                ps.closeCursor(id, completionHandler);
            }
        }
    }
}
