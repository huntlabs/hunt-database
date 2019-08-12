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

module hunt.database.base.impl.SqlConnectionBase;

import hunt.database.base.PreparedQuery;
import hunt.database.base.impl.command.PrepareStatementCommand;
// import io.vertx.core.*;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SqlConnectionBase(C) : SqlClientBase!(C) 
        if(is(C : SqlConnectionBase)) {

    protected Context context;
    protected Connection conn;

    protected this(Context context, Connection conn) {
        this.context = context;
        this.conn = conn;
    }

    C prepare(string sql, Handler!(AsyncResult!(PreparedQuery)) handler) {
        schedule(new PrepareStatementCommand(sql), (cr) {
            if (cr.succeeded()) {
                handler.handle(Future.succeededFuture(new PreparedQueryImpl(conn, context, cr.result())));
            } else {
                handler.handle(Future.failedFuture(cr.cause()));
            }
        });
        return cast(C) this;
    }
}
