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
module hunt.database.driver.postgresql.impl.PostgreSQLConnectionImpl;

import hunt.database.driver.postgresql.impl.PostgreSQLConnectionFactory;
import hunt.database.driver.postgresql.impl.PostgreSQLSocketConnection;

import hunt.database.driver.postgresql.PostgreSQLConnectOptions;
import hunt.database.driver.postgresql.PostgreSQLConnection;
import hunt.database.driver.postgresql.PostgreSQLNotification;
import hunt.database.driver.postgresql.PgUtil;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.PrepareStatementCommand;
import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.SqlConnectionImpl;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.SqlClient;
import hunt.database.base.Tuple;

import hunt.collection.List;
import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.StringBuilder;


alias PgNamedQueryDesc = NamedQueryDesc!("$", true);

/**
 * 
 */
class PgConnectionImpl : SqlConnectionImpl!(PgConnectionImpl), PgConnection  {

    private PgConnectionFactory factory;
    private PgNotificationHandler _notificationHandler;
    private PgSocketConnection _socketConn;

    this(PgConnectionFactory factory, DbConnection conn) {
        super(conn);
        _socketConn = cast(PgSocketConnection)conn;

        this.factory = factory;
    }

    override PgConnectionImpl query(string sql, RowSetHandler handler) {
        return super.query(sql, handler);
    }

    override PgConnectionImpl preparedQuery(string sql, RowSetHandler handler) {
        return super.preparedQuery(sql, handler);
    }

    override PgConnectionImpl preparedQuery(string sql, Tuple arguments, RowSetHandler handler) {
        return super.preparedQuery(sql, arguments, handler);
    }

    override PgConnectionImpl preparedBatch(string sql, List!(Tuple) batch, RowSetHandler handler) {
        return super.preparedBatch(sql, batch, handler);
    }

    override
    PgConnection notificationHandler(PgNotificationHandler handler) {
        _notificationHandler = handler;
        return this;
    }

    override
    void handleNotification(int processId, string channel, string payload) {
        PgNotificationHandler handler = _notificationHandler;
        if (handler !is null) {
            handler(new PgNotification().setProcessId(processId).setChannel(channel).setPayload(payload));
        }
    }

    override
    int processId() {
        return conn.getProcessId();
    }

    override
    int secretKey() {
        return conn.getSecretKey();
    }

    override
    PgConnection cancelRequest(hunt.database.base.Common.VoidHandler handler) {
        implementationMissing(false);
        // Context current = Vertx.currentContext();
        // if (current == context) {
        //     factory.connect(ar -> {
        //         if (ar.succeeded()) {
        //             PgSocketConnection conn = ar.result();
        //             conn.sendCancelRequestMessage(this.processId(), this.secretKey(), handler);
        //         } else {
        //             handler.handle(Future.failedFuture(ar.cause()));
        //         }
        //     });
        // } else {
        //     context.runOnContext(v -> cancelRequest(handler));
        // }
        return this;
    }

    // override protected AbstractNamedQueryDesc getNamedQueryDesc(string sql) {
    //     return new PgNamedQueryDesc(sql);
    // }

    Future!NamedQuery prepareNamedQueryAsync(string sql) {
        version(HUNT_DB_DEBUG) trace(sql);
        auto f = new FuturePromise!NamedQuery();
        AbstractNamedQueryDesc queryDesc = new PgNamedQueryDesc(sql);

        scheduleThen!(PreparedStatement)(new PrepareStatementCommand(queryDesc.getSql()), 
            (CommandResponse!PreparedStatement ar) {
                if (ar.succeeded()) {
                    NamedQueryImpl queryImpl = new PgNamedQueryImpl(conn, ar.result(), queryDesc);
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
        return f.get(awaittingTimeout);
    }       

    string escapeIdentifier(string identifier) {
        return PgUtil.escapeIdentifier(null, identifier).toString();
    }

    string escapeLiteral(string literal) {
        scope StringBuilder sb = new StringBuilder((cast(int)literal.length + 10) / 10 * 11); // Add 10% for escaping.
        PgUtil.escapeLiteral(sb, literal, _socketConn.getStandardConformingStrings());
        return sb.toString();
    } 


    /* ----------------------------- Static Metholds ---------------------------- */

    static void connect(PgConnectOptions options, AsyncResultHandler!(PgConnection) handler) {
        PgConnectionFactory client = new PgConnectionFactory(options);
        version(HUNT_DB_DEBUG) trace("connecting ...");
        client.connectAndInit( (AsyncResult!(DbConnection) ar) {
            version(HUNT_DB_DEBUG) info("connection result: ", ar.succeeded());
            if (ar.succeeded()) {
                DbConnection conn = ar.result();
                PgConnectionImpl p = new PgConnectionImpl(client, conn);
                conn.initHolder(p);
                if(handler !is null) {
                    handler(succeededResult!(PgConnection)(p));
                }
            } else if(handler !is null) {
                handler(failedResult!(PgConnection)(ar.cause()));
            }
        });
    }

}



import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.NamedQueryImpl;
import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.RowDesc;

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PreparedStatement;

import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;
import std.variant;

class PgNamedQueryImpl : NamedQueryImpl {

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

        // RowDesc rowDesc = getPreparedStatement().rowDesc();
        // warning(rowDesc.toString());

        _parameters[name] = value;
    }

}