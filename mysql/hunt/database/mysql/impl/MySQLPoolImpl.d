module hunt.database.mysql.impl.MySQLPoolImpl;

import hunt.database.mysql.impl.MySQLConnectionFactory;
import hunt.database.mysql.impl.MySQLConnectionImpl;

import hunt.database.mysql.MySQLConnectOptions;
import hunt.database.mysql.MySQLPool;

import hunt.database.base.AsyncResult;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PoolBase;
import hunt.database.base.impl.SqlConnectionImpl;
import hunt.database.base.PoolOptions;
import hunt.database.base.Transaction;
import hunt.database.base.SqlConnection;

/**
 * 
 */
class MySQLPoolImpl : PoolBase!(MySQLPoolImpl), MySQLPool {
    private MySQLConnectionFactory factory;

    this(MySQLConnectOptions connectOptions, PoolOptions poolOptions) {
        super(poolOptions);
        this.factory = new MySQLConnectionFactory(connectOptions);
    }

    override void connect(AsyncDbConnectionHandler completionHandler) {
        factory.connect(completionHandler);
    }

    override protected SqlConnection wrap(DbConnection conn) {
        return new MySQLConnectionImpl(factory, conn);
    }

    // override void begin(Handler!(AsyncResult!(Transaction)) handler) {
    //     throw new UnsupportedOperationException("Transaction is not supported for now");
    // }

    override protected void doClose() {
        factory.close();
        super.doClose();
    }
}
