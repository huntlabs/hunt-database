/*
 * Copyright (C) 2017 Julien Viet
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
module test.pgclient.PgTransactionTest;

import test.Common;
import test.pgclient.PgClientTestBase;

import hunt.database.base;
import hunt.database.base.impl;
import hunt.database.postgresql;
import hunt.database.postgresql.impl;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.Object;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;


class PgTransactionTest : PgClientTestBase!(Transaction) {

    private PgPool pool;

    private Consumer!(Action1!SqlConnection) sqlConnectionConnector;

    // this() {
    //     connector = handler -> {
    //         if (pool == null) {
    //             pool = PgPool.pool(vertx, new PgConnectOptions(options), new PoolOptions().setMaxSize(1));
    //         }
    //         pool.begin(handler);
    //     };
    // }
    this() {
        connector = (handler) {
            trace("Initializing connect ...");
            PgConnectionImpl.connect(options, (AsyncResult!PgConnection ar) {
                // mapping PgConnection to SqlConnection
                // handler(ar.map!(SqlConnection)( p => p));

                if(ar.succeeded()) {
                    PgConnectionImpl conn = cast(PgConnectionImpl)ar.result();
                    Transaction tx = conn.begin(true);
                    handler(tx);
                } else {
                    warning(ar.cause().msg);
                }
            });
        };

        sqlConnectionConnector = (handler) {
            trace("Initializing connect ...");
            PgConnectionImpl.connect(options, (AsyncResult!PgConnection ar) {
                // mapping PgConnection to SqlConnection
                // handler(ar.map!(SqlConnection)( p => p));

                if(ar.succeeded()) {
                    handler(ar.result());
                } else {
                    warning(ar.cause().msg);
                }
            });
        };
    }    
    

    @Test
    void testReleaseConnectionOnCommit() {
        connector((Transaction conn) {
            conn.query("UPDATE Fortune SET message = 'Whatever' WHERE id = 9", (AsyncResult!RowSet ar) {
                trace("running here");
                RowSet result = asyncAssertSuccess(ar);
                assert(1 == result.rowCount());
                conn.commit((VoidAsyncResult ar2) {
                    trace("running here");
                    Void v = asyncAssertSuccess!Void(ar2);
                    trace("running here: ", v is null);
                    conn.close();
                    // Try acquire a connection
                    // pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
                    //     async.complete();
                    // }));
                });
            });
        });
    }

    @Test
    void testReleaseConnectionOnRollback() {
        connector((Transaction conn) {
            conn.query("UPDATE Fortune SET message = 'Whatever' WHERE id = 9", (AsyncResult!RowSet ar) {
                trace("running here");
                RowSet result = asyncAssertSuccess(ar);
                assert(1 == result.rowCount());
                conn.rollback((VoidAsyncResult ar2)  {
                    trace("running here");
                    Void v = asyncAssertSuccess!Void(ar2);
                    trace("running here: ", v is null);
                    conn.close();
                    // Try acquire a connection
                    // pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
                    //     async.complete();
                    // }));
                });
            });
        });
    }

    @Test
    void testReleaseConnectionOnSetRollback() {
        connector((Transaction conn) {
            conn.abortHandler((VoidAsyncResult ar)  {
                trace("running here");
                Void v = asyncAssertSuccess!Void(ar);
                trace("running here: ", v is null);
                // Try acquire the same connection on rollback
                // pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
                //     async.complete();
                // }));
            });
            // Failure will abort
            conn.query("SELECT whatever from DOES_NOT_EXIST", (AsyncResult!RowSet ar) {
                trace("running here");
                Throwable t = asyncAssertFailure(ar);
                if(t !is null) {
                    info(t.msg);
                }
                conn.close();
             });
        });
    }

    @Test
    void testCommitWithPreparedQuery() {
        connector((Transaction conn) {
            conn.preparedQuery("INSERT INTO Fortune (id, message) VALUES ($1, $2);", 
                    Tuple.of(13, "test message1"), (RowSetAsyncResult ar) {
                trace("running here");
                RowSet result = asyncAssertSuccess(ar);
                assert(1 == result.rowCount());
                conn.commit((VoidAsyncResult ar2) {
                    trace("running here");
                    try {
                        Void v = asyncAssertSuccess!Void(ar2);
                    } catch(Exception ex) {
                        warning(ex.msg);
                    }

                    sqlConnectionConnector((SqlConnection conn2) {
                        trace("running here");
                        conn2.query("SELECT id, message from Fortune where id = 13", (RowSetAsyncResult ar) {
                            trace("running here");
                            RowSet rowSet = asyncAssertSuccess(ar);
                            assert(1 == rowSet.rowCount());
                            Row row = rowSet.iterator().front();
                            assert(13 == row.getInteger("id"));
                            assert("test message1" == row.getString("message"));
                            conn2.close();
                        });
                    });
                    conn.close();
                });
            });
        });
    }

    @Test
    void testCommitWithQuery() {
        connector((Transaction conn) {
            conn.query("INSERT INTO Fortune (id, message) VALUES (14, 'test message2');", 
                    (RowSetAsyncResult ar) {
                trace("running here");
                RowSet result = asyncAssertSuccess(ar);
                assert(1 == result.rowCount());

                conn.commit((VoidAsyncResult ar2) {
                    trace("running here");
                    // FIXME: Needing refactor or cleanup -@zxp at 8/31/2019, 10:52:36 PM
                    // using pool
                    
                    sqlConnectionConnector((SqlConnection conn2) {
                        trace("running here");
                        conn2.query("SELECT id, message from Fortune where id = 14", 
                                (RowSetAsyncResult ar) {
                            trace("running here");
                            RowSet rowSet = asyncAssertSuccess(ar);
                            assert(1 == rowSet.rowCount());
                            Row row = rowSet.iterator().front();
                            assert(14 == row.getInteger("id"));
                            assert("test message2" == row.getString("message"));
                            conn2.close();
                        });
                    });
                    
                    conn.close();
                });
            });
        });
    }

}
