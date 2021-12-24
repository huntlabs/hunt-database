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

module hunt.database.driver.mysql.impl.MySQLSocketConnection;


import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SocketConnectionBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.InitCommand;

import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging;
import hunt.net.AbstractConnection;
import hunt.net.Exceptions;
import hunt.util.Common;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class MySQLSocketConnection : SocketConnectionBase {

    this(AbstractConnection socket,
            bool cachePreparedStatements,
            int preparedStatementCacheSize,
            int preparedStatementCacheSqlLimit) {

        super(socket, cachePreparedStatements, preparedStatementCacheSize, 
                preparedStatementCacheSqlLimit, 1);
    }

    // override
    // void initialization() {
    //     super.initialization();
    // }

    void sendStartupMessage(string username, string password, string database, Map!(string, string) properties, 
            ResponseHandler!(DbConnection) completionHandler) {
        InitCommand cmd = new InitCommand(this, username, password, database, properties);
        cmd.handler = completionHandler;
        version(HUNT_DB_DEBUG) {
            trace("Sending InitCommand");
        }
        schedule(cmd);
    }
}
