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

import hunt.database.postgresql.PostgreSQLConnectOptions;
import hunt.database.postgresql.PostgreSQLConnection;
import hunt.database.postgresql.PostgreSQLNotification;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SqlConnectionImpl;
import hunt.database.base.AsyncResult;

// import io.vertx.core.Context;
// import io.vertx.core.Future;
// import io.vertx.core.Handler;
// import io.vertx.core.Vertx;

import hunt.Exceptions;

class PgConnectionImpl : SqlConnectionImpl!(PgConnectionImpl), PgConnection  {

    // static void connect(Vertx vertx, PgConnectOptions options, Handler!(AsyncResult!(PgConnection)) handler) {
    //     Context ctx = Vertx.currentContext();
    //     if (ctx !is null) {
    //         PgConnectionFactory client = new PgConnectionFactory(ctx, false, options);
    //         client.connectAndInit(ar -> {
    //             if (ar.succeeded()) {
    //                 Connection conn = ar.result();
    //                 PgConnectionImpl p = new PgConnectionImpl(client, ctx, conn);
    //                 conn.init(p);
    //                 handler.handle(Future.succeededFuture(p));
    //             } else {
    //                 handler.handle(Future.failedFuture(ar.cause()));
    //             }
    //         });
    //     } else {
    //         vertx.runOnContext(v -> {
    //             if (options.isUsingDomainSocket() && !vertx.isNativeTransportEnabled()) {
    //                 handler.handle(Future.failedFuture("Native transport is not available"));
    //             } else {
    //                 connect(vertx, options, handler);
    //             }
    //         });
    //     }
    // }

    private PgConnectionFactory factory;
    private Handler!(PgNotification) notificationHandler;

    this(PgConnectionFactory factory, Context context, Connection conn) {
        super(context, conn);

        this.factory = factory;
    }

    override
    PgConnection notificationHandler(Handler!(PgNotification) handler) {
        notificationHandler = handler;
        return this;
    }


    void handleNotification(int processId, string channel, string payload) {
        Handler!(PgNotification) handler = notificationHandler;
        if (handler !is null) {
            handler.handle(new PgNotification().setProcessId(processId).setChannel(channel).setPayload(payload));
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
