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

import hunt.database.base.SqlResult;
import io.vertx.core.AsyncResult;
import io.vertx.core.Handler;

import java.util.function.Function;

/**
 * A query result handler for building a {@link SqlResult}.
 */
class SqlResultBuilder!(T, R extends SqlResultBase!(T, R), L extends SqlResult!(T)) implements QueryResultHandler!(T), Handler!(AsyncResult!(Boolean)) {

  private final Handler!(AsyncResult!(L)) handler;
  private final Function!(T, R) factory;
  private R first;
  private boolean suspended;

  SqlResultBuilder(Function!(T, R) factory, Handler!(AsyncResult!(L)) handler) {
    this.factory = factory;
    this.handler = handler;
  }

  override
  void handleResult(int updatedCount, int size, RowDesc desc, T result) {
    R r = factory.apply(result);
    r.updated = updatedCount;
    r.size = size;
    r.columnNames = desc !is null ? desc.columnNames() : null;
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

  override
  void handle(AsyncResult!(Boolean) res) {
    suspended = res.succeeded() && res.result();
    handler.handle((AsyncResult!(L)) res.map(first));
  }

  boolean isSuspended() {
    return suspended;
  }
}
