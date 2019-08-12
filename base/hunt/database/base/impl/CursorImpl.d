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

import hunt.database.base.AsyncResult;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import hunt.database.base.Cursor;
import hunt.database.base.RowSet;
import hunt.database.base.Tuple;

import java.util.UUID;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class CursorImpl implements Cursor {

  private final PreparedQueryImpl ps;
  private final Tuple params;

  private String id;
  private boolean closed;
  private SqlResultBuilder!(RowSet, RowSetImpl, RowSet) result;

  CursorImpl(PreparedQueryImpl ps, Tuple params) {
    this.ps = ps;
    this.params = params;
  }

  override
  synchronized boolean hasMore() {
    if (result is null) {
      throw new IllegalStateException("No current cursor read");
    }
    return result.isSuspended();
  }

  override
  synchronized void read(int count, Handler!(AsyncResult!(RowSet)) handler) {
    if (id is null) {
      id = UUID.randomUUID().toString();
      result = new SqlResultBuilder<>(RowSetImpl.FACTORY, handler);
      ps.execute(params, count, id, false, false, RowSetImpl.COLLECTOR, result, result);
    } else if (result.isSuspended()) {
      result = new SqlResultBuilder<>(RowSetImpl.FACTORY, handler);
      ps.execute(params, count, id, true, false, RowSetImpl.COLLECTOR, result, result);
    } else {
      throw new IllegalStateException();
    }
  }

  override
  synchronized void close(Handler!(AsyncResult!(Void)) completionHandler) {
    if (!closed) {
      closed = true;
      if (id is null) {
        completionHandler.handle(Future.succeededFuture());
      } else {
        String id = this.id;
        this.id = null;
        result = null;
        ps.closeCursor(id, completionHandler);
      }
    }
  }
}
