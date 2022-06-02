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

module hunt.database.driver.postgresql.impl.PostgreSQLPoolImpl;

import hunt.database.driver.postgresql.impl.PostgreSQLConnectionFactory;
import hunt.database.driver.postgresql.impl.PostgreSQLConnectionImpl;

import hunt.database.driver.postgresql.PostgreSQLConnectOptions;
import hunt.database.driver.postgresql.PostgreSQLPool;

import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PoolBase;
import hunt.database.base.impl.SqlConnectionImpl;
import hunt.database.base.PoolOptions;
import hunt.database.base.SqlConnection;

/**
 * Todo :
 *
 * - handle timeout when acquiring a connection
 * - for per statement pooling, have several physical connection and use the less busy one to avoid head of line blocking effect
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class PgPoolImpl : PoolBase!(PgPoolImpl), PgPool {

    private PgConnectionFactory factory;

    this(PgConnectOptions connectOptions, PoolOptions poolOptions) {
        super(poolOptions);
        this.factory = new PgConnectionFactory(connectOptions);
    }

    override
    void connect(AsyncDbConnectionHandler completionHandler) {
        factory.connectAndInit(completionHandler);
    }

    override
    protected SqlConnection wrap(DbConnection conn) {
        PgConnectionImpl impl = new PgConnectionImpl(factory, conn);
        impl.awaittingTimeout = options.awaittingTimeout();
        return impl;
    }

    override
    protected void doClose() {
        factory.close();
        super.doClose();
    }
}
