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

import hunt.database.base.Cursor;
import hunt.database.base.RowSet;
import hunt.database.base.RowStream;
import hunt.database.base.Row;
import hunt.database.base.Tuple;
import io.vertx.core.AsyncResult;
import io.vertx.core.Handler;

import java.util.Iterator;

class RowStreamImpl implements RowStream!(Row), Handler!(AsyncResult!(RowSet)) {

  private final PreparedQueryImpl ps;
  private final int fetch;
  private final Tuple params;

  private Handler!(Void) endHandler;
  private Handler!(Row) rowHandler;
  private Handler!(Throwable) exceptionHandler;
  private long demand;
  private boolean emitting;
  private Cursor cursor;

  private Iterator!(Row) result;

  RowStreamImpl(PreparedQueryImpl ps, int fetch, Tuple params) {
    this.ps = ps;
    this.fetch = fetch;
    this.params = params;
    this.demand = Long.MAX_VALUE;
  }

  override
  synchronized RowStream!(Row) exceptionHandler(Handler!(Throwable) handler) {
    exceptionHandler = handler;
    return this;
  }

  override
  RowStream!(Row) handler(Handler!(Row) handler) {
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
    c.read(fetch, this);
    return this;
  }

  override
  synchronized RowStream!(Row) pause() {
    demand = 0L;
    return this;
  }

  RowStream!(Row) fetch(long amount) {
    if (amount < 0L) {
      throw new IllegalArgumentException("Invalid fetch amount " + amount);
    }
    synchronized (this) {
      demand += amount;
      if (demand < 0L) {
        demand = Long.MAX_VALUE;
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
    return fetch(Long.MAX_VALUE);
  }

  override
  synchronized RowStream!(Row) endHandler(Handler!(Void) handler) {
    endHandler = handler;
    return this;
  }

  override
  void handle(AsyncResult!(RowSet) ar) {
    if (ar.failed()) {
      Handler!(Throwable) handler;
      synchronized (RowStreamImpl.this) {
        cursor = null;
        handler = exceptionHandler;
      }
      if (handler !is null) {
        handler.handle(ar.cause());
      }
    } else {
      result = ar.result().iterator();
      checkPending();
    }
  }

  override
  void close() {
    close(ar -> {});
  }

  override
  void close(Handler!(AsyncResult!(Void)) completionHandler) {
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
    synchronized (RowStreamImpl.this) {
      if (emitting) {
        return;
      }
      emitting = true;
    }
    while (true) {
      synchronized (RowStreamImpl.this) {
        if (demand == 0L || result is null) {
          emitting = false;
          break;
        }
        Handler handler;
        Object event;
        if (result.hasNext()) {
          handler = rowHandler;
          event = result.next();
          if (demand != Long.MAX_VALUE) {
            demand--;
          }
        } else {
          result = null;
          emitting = false;
          if (cursor.hasMore()) {
            cursor.read(fetch, this);
            break;
          } else {
            cursor = null;
            handler = endHandler;
            event = null;
          }
        }
        if (handler !is null) {
          handler.handle(event);
        }
      }
    }
  }
}
