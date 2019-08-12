module hunt.database.mysql.impl.MySQLPoolImpl;

import io.vertx.core.AsyncResult;
import io.vertx.core.Context;
import io.vertx.core.Handler;
import io.vertx.core.Vertx;
import hunt.database.mysql.MySQLConnectOptions;
import hunt.database.mysql.MySQLPool;
import hunt.database.base.PoolOptions;
import hunt.database.base.Transaction;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PoolBase;
import hunt.database.base.impl.SqlConnectionImpl;

class MySQLPoolImpl : PoolBase!(MySQLPoolImpl) implements MySQLPool {
  private final MySQLConnectionFactory factory;

  MySQLPoolImpl(Context context, boolean closeVertx, MySQLConnectOptions connectOptions, PoolOptions poolOptions) {
    super(context, closeVertx, poolOptions);
    this.factory = new MySQLConnectionFactory(context, Vertx.currentContext() !is null, connectOptions);
  }

  override
  void connect(Handler!(AsyncResult!(Connection)) completionHandler) {
    factory.connect(completionHandler);
  }

  override
  protected SqlConnectionImpl wrap(Context context, Connection conn) {
    return new MySQLConnectionImpl(factory, context, conn);
  }

  override
  void begin(Handler!(AsyncResult!(Transaction)) handler) {
    throw new UnsupportedOperationException("Transaction is not supported for now");
  }

  override
  protected void doClose() {
    factory.close();
    super.doClose();
  }
}
