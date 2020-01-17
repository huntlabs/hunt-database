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

import hunt.database.base.impl.Connection;
import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.NamedQueryImpl;
import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.SqlClientBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.PrepareStatementCommand;

import hunt.database.base.AsyncResult;
import hunt.database.base.PreparedQuery;

import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.AbstractConnection;


/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SqlConnectionBase(C) : SqlClientBase!(C) { 
    // if(is(C : SqlConnectionBase!(C))) 

    protected DbConnection conn;

    protected this(DbConnection conn) {
        this.conn = conn;
    }

    C prepare(string sql, PreparedQueryHandler handler) {
        version(HUNT_DB_DEBUG) trace(sql);
        scheduleThen!(PreparedStatement)(new PrepareStatementCommand(sql), 
            (CommandResponse!PreparedStatement cr) {
                if(handler !is null) {
                    if (cr.succeeded()) {
                        handler(succeededResult!(PreparedQuery)(new PreparedQueryImpl(conn, cr.result())));
                    } else {
                        handler(failedResult!(PreparedQuery)(cr.cause()));
                    }
                }
            }
        );
        return cast(C) this;
    }

    Future!PreparedQuery prepareAsync(string sql) {
        version(HUNT_DB_DEBUG) trace(sql);
        auto f = new FuturePromise!PreparedQuery();

        scheduleThen!(PreparedStatement)(new PrepareStatementCommand(sql), 
            (CommandResponse!PreparedStatement ar) {
                if (ar.succeeded()) {
                    f.succeeded(new PreparedQueryImpl(conn, ar.result()));
                } else {
                    f.failed(cast(Exception)ar.cause()); 
                }
            }
        );
        
        return f;
    }

    PreparedQuery prepare(string sql) {
        auto f = prepareAsync(sql);
        version(HUNT_DEBUG) warning("try to get a prepare result");
        import core.time;
        return f.get(5.seconds);
    }

    // protected AbstractNamedQueryDesc getNamedQueryDesc(string sql) {
    //     throw new NotImplementedException("getNamedQueryDesc");
    // }

    // Future!NamedQuery prepareNamedQueryAsync(string sql) {
    //     version(HUNT_DB_DEBUG) trace(sql);
    //     auto f = new FuturePromise!NamedQuery();
    //     AbstractNamedQueryDesc queryDesc = getNamedQueryDesc(sql);

    //     scheduleThen!(PreparedStatement)(new PrepareStatementCommand(queryDesc.getSql()), 
    //         (CommandResponse!PreparedStatement ar) {
    //             if (ar.succeeded()) {
    //                 NamedQueryImpl queryImpl = new NamedQueryImpl(conn, ar.result(), queryDesc);
    //                 f.succeeded(queryImpl);
    //             } else {
    //                 f.failed(cast(Exception)ar.cause()); 
    //             }
    //         }
    //     );
        
    //     return f;
    // }

    // NamedQuery prepareNamedQuery(string sql) {
    //     auto f = prepareNamedQueryAsync(sql);
    //     return f.get();
    // }    
}

