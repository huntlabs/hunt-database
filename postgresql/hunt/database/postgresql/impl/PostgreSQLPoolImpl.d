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

module hunt.database.postgresql.impl.PostgreSQLPoolImpl;

// import hunt.database.postgresql.*;
import hunt.database.base.PoolOptions;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PoolBase;
import hunt.database.base.impl.SqlConnectionImpl;
// import io.vertx.core.*;

/**
 * Todo :
 *
 * - handle timeout when acquiring a connection
 * - for per statement pooling, have several physical connection and use the less busy one to avoid head of line blocking effect
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
// class PgPoolImpl : PoolBase!(PgPoolImpl), PgPool {

//     private PgConnectionFactory factory;

//     this(Context context, boolean closeVertx, PgConnectOptions connectOptions, PoolOptions poolOptions) {
//         super(context, closeVertx, poolOptions);
//         this.factory = new PgConnectionFactory(context, Vertx.currentContext() !is null, connectOptions);
//     }

//     override
//     void connect(Handler!(AsyncResult!(Connection)) completionHandler) {
//         factory.connectAndInit(completionHandler);
//     }

//     override
//     protected SqlConnectionImpl wrap(Context context, Connection conn) {
//         return new PgConnectionImpl(factory, context, conn);
//     }

//     override
//     protected void doClose() {
//         factory.close();
//         super.doClose();
//     }
// }
