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

module hunt.database.base.impl.SqlConnectionImpl;

import hunt.database.base.SqlConnection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.Transaction;
import io.vertx.core.*;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SqlConnectionImpl!(C extends SqlConnectionImpl) extends SqlConnectionBase!(C) implements SqlConnection, Connection.Holder {

  private volatile Handler!(Throwable) exceptionHandler;
  private volatile Handler!(Void) closeHandler;
  private TransactionImpl tx;

  SqlConnectionImpl(Context context, Connection conn) {
    super(context, conn);
  }

  override
  void handleClosed() {
    Handler!(Void) handler = closeHandler;
    if (handler != null) {
      context.runOnContext(handler);
    }
  }

  override
  <R> void schedule(CommandBase!(R) cmd, Handler<? super CommandResponse!(R)> handler) {
    cmd.handler = cr -> {
      // Tx might be gone ???
      cr.scheduler = this;
      handler.handle(cr);
    };
    schedule(cmd);
  }

  protected void schedule(CommandBase<?> cmd) {
    if (context == Vertx.currentContext()) {
      if (tx != null) {
        tx.schedule(cmd);
      } else {
        conn.schedule(cmd);
      }
    } else {
      context.runOnContext(v -> {
        schedule(cmd);
      });
    }
  }

  override
  void handleException(Throwable err) {
    Handler!(Throwable) handler = exceptionHandler;
    if (handler != null) {
      context.runOnContext(v -> {
        handler.handle(err);
      });
    } else {
      err.printStackTrace();
    }
  }

  override
  boolean isSSL() {
    return conn.isSsl();
  }

  override
  C closeHandler(Handler!(Void) handler) {
    closeHandler = handler;
    return (C) this;
  }

  override
  C exceptionHandler(Handler!(Throwable) handler) {
    exceptionHandler = handler;
    return (C) this;
  }

  override
  Transaction begin() {
    return begin(false);
  }

  Transaction begin(boolean closeOnEnd) {
    if (tx != null) {
      throw new IllegalStateException();
    }
    tx = new TransactionImpl(context, conn, v -> {
      tx = null;
      if (closeOnEnd) {
        close();
      }
    });
    return tx;
  }

  abstract void handleNotification(int processId, String channel, String payload);

  override
  void close() {
    if (context == Vertx.currentContext()) {
      if (tx != null) {
        tx.rollback(ar -> conn.close(this));
        tx = null;
      } else {
        conn.close(this);
      }
    } else {
      context.runOnContext(v -> close());
    }
  }
}
