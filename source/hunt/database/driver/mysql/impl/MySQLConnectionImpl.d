module hunt.database.driver.mysql.impl.MySQLConnectionImpl;

import hunt.database.driver.mysql.impl.MySQLConnectionFactory;
import hunt.database.driver.mysql.impl.MySQLCollation;

import hunt.database.driver.mysql.MySQLConnectOptions;
import hunt.database.driver.mysql.MySQLConnection;
import hunt.database.driver.mysql.MySQLSetOption;
import hunt.database.driver.mysql.impl.command.ChangeUserCommand;
import hunt.database.driver.mysql.impl.command.DebugCommand;
import hunt.database.driver.mysql.impl.command.InitDbCommand;
import hunt.database.driver.mysql.impl.command.PingCommand;
import hunt.database.driver.mysql.impl.command.ResetConnectionCommand;
import hunt.database.driver.mysql.impl.command.SetOptionCommand;
import hunt.database.driver.mysql.impl.command.StatisticsCommand;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Transaction;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SqlConnectionImpl;

import hunt.logging.ConsoleLogger;

import hunt.collection.List;
import hunt.Exceptions;


class MySQLConnectionImpl : SqlConnectionImpl!(MySQLConnectionImpl), MySQLConnection {

    static void connect(MySQLConnectOptions options, AsyncResultHandler!(MySQLConnection) handler) {
        MySQLConnectionFactory client = new MySQLConnectionFactory(options);
        version(HUNT_DB_DEBUG) trace("connecting ...");
        client.connect( (ar) {
            version(HUNT_DB_DEBUG) info("connection result: ", ar.succeeded());
            if (ar.succeeded()) {
                DbConnection conn = ar.result();
                MySQLConnectionImpl p = new MySQLConnectionImpl(client, conn);
                conn.initHolder(p);
                if(handler !is null) {
                    handler(succeededResult!(MySQLConnection)(p));
                }
            } else if(handler !is null) {
                handler(failedResult!(MySQLConnection)(ar.cause()));
            }
        });
    }

    private MySQLConnectionFactory factory;

    this(MySQLConnectionFactory factory, DbConnection conn) {
        super(conn);

        this.factory = factory;
    }

    override
    void handleNotification(int processId, string channel, string payload) {
        throw new UnsupportedOperationException();
    }

    override
    Transaction begin() {
        throw new UnsupportedOperationException("Transaction is not supported for now");
    }

    override
    Transaction begin(bool closeOnEnd) {
        throw new UnsupportedOperationException("Transaction is not supported for now");
    }

    override
    MySQLConnection ping(AsyncVoidHandler handler) {
        PingCommand cmd = new PingCommand();
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection specifySchema(string schemaName, AsyncVoidHandler handler) {
        InitDbCommand cmd = new InitDbCommand(schemaName);
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection getInternalStatistics(AsyncResultHandler!(string) handler) {
        StatisticsCommand cmd = new StatisticsCommand();
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection setOption(MySQLSetOption option, AsyncVoidHandler handler) {
        SetOptionCommand cmd = new SetOptionCommand(option);
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection resetConnection(AsyncVoidHandler handler) {
        ResetConnectionCommand cmd = new ResetConnectionCommand();
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection dumpDebug(AsyncVoidHandler handler) {
        DebugCommand cmd = new DebugCommand();
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }

    override
    MySQLConnection changeUser(MySQLConnectOptions options, AsyncVoidHandler handler) {
        MySQLCollation collation;
        try {
            collation = MySQLCollation.valueOfName(options.getCollation());
        } catch (IllegalArgumentException e) {
            handler(failedResult!(Object)(e));
            return this;
        }
        ChangeUserCommand cmd = new ChangeUserCommand(options.getUser(), options.getPassword(), 
            options.getDatabase(), collation, options.getProperties());
        cmd.handler = (r) { handler(r); };
        schedule(cmd);
        return this;
    }
}
