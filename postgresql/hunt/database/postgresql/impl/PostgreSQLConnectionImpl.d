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
module hunt.database.postgresql.impl.PostgreSQLConnectionImpl;

import hunt.database.postgresql.impl.PostgreSQLConnectionFactory;

import hunt.database.postgresql.PostgreSQLConnectOptions;
import hunt.database.postgresql.PostgreSQLConnection;
import hunt.database.postgresql.PostgreSQLNotification;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SqlConnectionImpl;
import hunt.database.base.SqlResult;
import hunt.database.base.RowSet;
import hunt.database.base.Row;
import hunt.database.base.SqlClient;
import hunt.database.base.Tuple;


import hunt.collection.List;
import hunt.Exceptions;


class PgConnectionImpl : SqlConnectionImpl!(PgConnectionImpl), PgConnection  {

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

    static void connect(PgConnectOptions options, AsyncResultHandler!(PgConnection) handler) {
        PgConnectionFactory client = new PgConnectionFactory(options);
        client.connectAndInit( (ar) {
            if (ar.succeeded()) {
                DbConnection conn = ar.result();
                PgConnectionImpl p = new PgConnectionImpl(client, conn);
                conn.initHolder(p);
                handler(succeededResult!(PgConnection)(p));
            } else {
                handler(failedResult!(PgConnection)(ar.cause()));
            }
        });
    }

    private PgConnectionFactory factory;
    private PgNotificationHandler _notificationHandler;

    this(PgConnectionFactory factory, DbConnection conn) {
        super(conn);

        this.factory = factory;
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
    PgConnection cancelRequest(VoidHandler handler) {
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
}
