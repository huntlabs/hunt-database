module hunt.database.mysql.impl.MySQLConnectionImpl;

import io.vertx.core.AsyncResult;
import io.vertx.core.Context;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import io.vertx.core.Vertx;

import hunt.database.mysql.MySQLConnectOptions;
import hunt.database.mysql.MySQLConnection;
import hunt.database.mysql.MySQLSetOption;
import hunt.database.mysql.impl.command.ChangeUserCommand;
import hunt.database.mysql.impl.command.DebugCommand;
import hunt.database.mysql.impl.command.InitDbCommand;
import hunt.database.mysql.impl.command.PingCommand;
import hunt.database.mysql.impl.command.ResetConnectionCommand;
import hunt.database.mysql.impl.command.SetOptionCommand;
import hunt.database.mysql.impl.command.StatisticsCommand;

import hunt.database.base.Transaction;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SqlConnectionImpl;

class MySQLConnectionImpl : SqlConnectionImpl!(MySQLConnectionImpl) implements MySQLConnection {

  static void connect(Vertx vertx, MySQLConnectOptions options, Handler!(AsyncResult!(MySQLConnection)) handler) {
    Context ctx = Vertx.currentContext();
    if (ctx !is null) {
      MySQLConnectionFactory client = new MySQLConnectionFactory(ctx, false, options);
      client.connect(ar-> {
        if (ar.succeeded()) {
          Connection conn = ar.result();
          MySQLConnectionImpl p = new MySQLConnectionImpl(client, ctx, conn);
          conn.init(p);
          handler.handle(Future.succeededFuture(p));
        } else {
          handler.handle(Future.failedFuture(ar.cause()));
        }
      });
    } else {
      vertx.runOnContext(v -> {
        connect(vertx, options, handler);
      });
    }
  }

  private final MySQLConnectionFactory factory;

  MySQLConnectionImpl(MySQLConnectionFactory factory, Context context, Connection conn) {
    super(context, conn);

    this.factory = factory;
  }

  override
  void handleNotification(int processId, String channel, String payload) {
    throw new UnsupportedOperationException();
  }

  override
  Transaction begin() {
    throw new UnsupportedOperationException("Transaction is not supported for now");
  }

  override
  Transaction begin(boolean closeOnEnd) {
    throw new UnsupportedOperationException("Transaction is not supported for now");
  }

  override
  MySQLConnection ping(Handler!(AsyncResult!(Void)) handler) {
    PingCommand cmd = new PingCommand();
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection specifySchema(String schemaName, Handler!(AsyncResult!(Void)) handler) {
    InitDbCommand cmd = new InitDbCommand(schemaName);
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection getInternalStatistics(Handler!(AsyncResult!(String)) handler) {
    StatisticsCommand cmd = new StatisticsCommand();
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection setOption(MySQLSetOption option, Handler!(AsyncResult!(Void)) handler) {
    SetOptionCommand cmd = new SetOptionCommand(option);
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection resetConnection(Handler!(AsyncResult!(Void)) handler) {
    ResetConnectionCommand cmd = new ResetConnectionCommand();
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection debug(Handler!(AsyncResult!(Void)) handler) {
    DebugCommand cmd = new DebugCommand();
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }

  override
  MySQLConnection changeUser(MySQLConnectOptions options, Handler!(AsyncResult!(Void)) handler) {
    MySQLCollation collation;
    try {
      collation = MySQLCollation.valueOfName(options.getCollation());
    } catch (IllegalArgumentException e) {
      handler.handle(Future.failedFuture(e));
      return this;
    }
    ChangeUserCommand cmd = new ChangeUserCommand(options.getUser(), options.getPassword(), options.getDatabase(), collation, options.getProperties());
    cmd.handler = handler;
    schedule(cmd);
    return this;
  }
}
