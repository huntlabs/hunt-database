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
module hunt.database.base.impl.TransactionImpl;

import hunt.database.base.Transaction;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.QueryCommandBase;
import hunt.database.base.impl.command.SimpleQueryCommand;
import hunt.database.base.RowSet;
import io.vertx.core.*;

import java.util.ArrayDeque;
import java.util.Deque;

class TransactionImpl : SqlConnectionBase!(TransactionImpl) implements Transaction {

  private static final int ST_BEGIN = 0;
  private static final int ST_PENDING = 1;
  private static final int ST_PROCESSING = 2;
  private static final int ST_COMPLETED = 3;

  private final Handler!(Void) disposeHandler;
  private Deque<CommandBase<?>> pending = new ArrayDeque<>();
  private Handler!(Void) failedHandler;
  private int status = ST_BEGIN;

  TransactionImpl(Context context, Connection conn, Handler!(Void) disposeHandler) {
    super(context, conn);
    this.disposeHandler = disposeHandler;
    doSchedule(doQuery("BEGIN", this::afterBegin));
  }

  private void doSchedule(CommandBase<?> cmd) {
    if (context == Vertx.currentContext()) {
      conn.schedule(cmd);
    } else {
      context.runOnContext(v -> conn.schedule(cmd));
    }
  }

  private synchronized void afterBegin(AsyncResult<?> ar) {
    if (ar.succeeded()) {
      status = ST_PENDING;
    } else {
      status = ST_COMPLETED;
    }
    checkPending();
  }

  private boolean isComplete(CommandBase<?> cmd) {
    if (cmd instanceof QueryCommandBase<?>) {
      String sql = ((QueryCommandBase) cmd).sql().trim();
      return sql.equalsIgnoreCase("COMMIT") || sql.equalsIgnoreCase("ROLLBACK");
    }
    return false;
  }

  private synchronized void checkPending() {
    switch (status) {
      case ST_BEGIN:
        break;
      case ST_PENDING: {
        CommandBase<?> cmd = pending.poll();
        if (cmd !is null) {
          if (isComplete(cmd)) {
            status = ST_COMPLETED;
          } else {
            wrap(cmd);
            status = ST_PROCESSING;
          }
          doSchedule(cmd);
        }
        break;
      }
      case ST_PROCESSING:
        break;
      case ST_COMPLETED: {
        if (pending.size() > 0) {
          VertxException err = new VertxException("Transaction already completed");
          CommandBase<?> cmd;
          while ((cmd = pending.poll()) !is null) {
            cmd.fail(err);
          }
        }
        break;
      }
    }
  }

  override
  <R> void schedule(CommandBase!(R) cmd, Handler<? super CommandResponse!(R)> handler) {
    cmd.handler = cr -> {
      cr.scheduler = this;
      handler.handle(cr);
    };
    schedule(cmd);
  }

  void schedule(CommandBase<?> cmd) {
    synchronized (this) {
      pending.add(cmd);
    }
    checkPending();
  }

  private <T> void wrap(CommandBase!(T) cmd) {
    Handler<? super CommandResponse!(T)> handler = cmd.handler;
    cmd.handler = ar -> {
      synchronized (TransactionImpl.this) {
        status = ST_PENDING;
        if (ar.txStatus() == TxStatus.FAILED) {
          // We won't recover from this so rollback
          CommandBase<?> c;
          while ((c = pending.poll()) !is null) {
            c.fail(new RuntimeException("rollback exception"));
          }
          Handler!(Void) h = failedHandler;
          if (h !is null) {
            context.runOnContext(h);
          }
          schedule(doQuery("ROLLBACK", ar2 -> {
            disposeHandler.handle(null);
            handler.handle(ar);
          }));
        } else {
          handler.handle(ar);
          checkPending();
        }
      }
    };
  }

  override
  void commit() {
    commit(null);
  }

  void commit(Handler!(AsyncResult!(Void)) handler) {
    switch (status) {
      case ST_BEGIN:
      case ST_PENDING:
      case ST_PROCESSING:
        schedule(doQuery("COMMIT", ar -> {
          disposeHandler.handle(null);
          if (handler !is null) {
            if (ar.succeeded()) {
              handler.handle(Future.succeededFuture());
            } else {
              handler.handle(Future.failedFuture(ar.cause()));
            }
          }
        }));
        break;
      case ST_COMPLETED:
        if (handler !is null) {
          handler.handle(Future.failedFuture("Transaction already completed"));
        }
        break;
    }
  }

  override
  void rollback() {
    rollback(null);
  }

  void rollback(Handler!(AsyncResult!(Void)) handler) {
    schedule(doQuery("ROLLBACK", ar -> {
      disposeHandler.handle(null);
      if (handler !is null) {
        handler.handle(ar.mapEmpty());
      }
    }));
  }

  override
  void close() {
    rollback();
  }

  override
  io.vertx.sqlclient.Transaction abortHandler(Handler!(Void) handler) {
    failedHandler = handler;
    return this;
  }

  private CommandBase doQuery(String sql, Handler!(AsyncResult!(RowSet)) handler) {
    SqlResultBuilder!(RowSet, RowSetImpl, RowSet) b = new SqlResultBuilder<>(RowSetImpl.FACTORY, handler);
    SimpleQueryCommand!(RowSet) cmd = new SimpleQueryCommand<>(sql, false, RowSetImpl.COLLECTOR, b);
    cmd.handler = b;
    return cmd;
  }
}
