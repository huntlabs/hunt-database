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
import hunt.database.driver.mysql.MySQLUtil;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Transaction;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.PrepareStatementCommand;
import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.SqlConnectionImpl;

import hunt.logging;

import hunt.collection.List;
import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.Exceptions;



alias MySQLNamedQueryDesc = NamedQueryDesc!("?", false);

/**
 * 
 */
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

    // override protected AbstractNamedQueryDesc getNamedQueryDesc(string sql) {
    //     return new MySQLNamedQueryDesc(sql);
    // }

    // protected AbstractNamedQueryDesc getNamedQueryDesc(string sql) {
    //     throw new NotImplementedException("getNamedQueryDesc");
    // }

    Future!NamedQuery prepareNamedQueryAsync(string sql) {
        version(HUNT_DB_DEBUG) trace(sql);
        auto f = new FuturePromise!NamedQuery("NamedQuery");
        AbstractNamedQueryDesc queryDesc = new MySQLNamedQueryDesc(sql);

        scheduleThen!(PreparedStatement)(new PrepareStatementCommand(queryDesc.getSql()), 
            (CommandResponse!PreparedStatement ar) {
                if (ar.succeeded()) {
                    NamedQueryImpl queryImpl = new MySQLNamedQueryImpl(conn, ar.result(), queryDesc);
                    f.succeeded(queryImpl);
                } else {
                    f.failed(ar.cause()); 
                }
            }
        );
        
        return f;
    }

    NamedQuery prepareNamedQuery(string sql) {
        auto f = prepareNamedQueryAsync(sql);
        version(HUNT_DEBUG) warning("try to get a result");
        import core.time;
        return f.get(awaittingTimeout);
    }       

    string escapeIdentifier(string identifier) {
// TODO: Tasks pending completion -@zxp at Fri, 20 Sep 2019 02:44:54 GMT        
// 
        return identifier;
    }

    string escapeLiteral(string literal) {
        return MySQLUtil.escapeLiteral(literal);
    }      
}


import hunt.database.driver.mysql.impl.codec.MySQLRowDesc;

import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.NamedQueryImpl;
import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.RowDesc;

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.ParamDesc;
import hunt.database.base.impl.PreparedStatement;

import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import std.variant;

/**
 * 
 */
class MySQLNamedQueryImpl : NamedQueryImpl {

    this(DbConnection conn, PreparedStatement ps, AbstractNamedQueryDesc queryDesc) {
        super(conn, ps, queryDesc);
    }

    void setParameter(string name, Variant value) {
        version(HUNT_DEBUG) {
            auto itemPtr = name in _parameters;
            if(itemPtr !is null) {
                warning("% will be overwrited with %s", name, value.toString());
            }
        }


        // TODO: Tasks pending completion -@zhangxueping at 2019-10-01T13:35:23+08:00
        // validate the type of parameter
        // hunt.database.driver.mysql.impl.codec.ColumnDefinition;

        // getPreparedStatement().paramDesc();

        // MySQLRowDesc rowDesc = cast(MySQLRowDesc)getPreparedStatement().rowDesc();
        // warning(rowDesc.toString());

        // ParamDesc pd = getPreparedStatement().paramDesc();
        // warning(pd.toString());

        _parameters[name] = value;
    }

}