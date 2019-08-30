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
module test.PreparedQueryTestBase;

import test.QueryTestBase;

import hunt.database.base;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;

alias SqlConnectionHandler = Action1!SqlConnection;

abstract class PreparedQueryTestBase : QueryTestBase {


    protected abstract string statement(string[] parts...);


    @Test
    void testPrepare() {
        connect((SqlConnection conn) {
            conn.prepare(statement("SELECT id, message from immutable where id=", ""), (AsyncResult!PreparedQuery ar)  {
                trace("running here");
                if(ar.succeeded()) {
                    conn.close();
                } else {
                    warning(ar.cause().msg);
                }
            });
        });
    }

    // @Test
    // void testPrepareError() {
    //     connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.prepare("SELECT whatever from DOES_NOT_EXIST", ctx.asyncAssertFailure(error -> {
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedQuery() {
    //     connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery(statement("SELECT * FROM immutable WHERE id=", ""), Tuple.of(1), ctx.asyncAssertSuccess(rowSet -> {
    //             ctx.assertEquals(1, rowSet.size());
    //             Tuple row = rowSet.iterator().next();
    //             ctx.assertEquals(1, row.getInteger(0));
    //             ctx.assertEquals("fortune: No such file or directory", row.getstring(1));
    //             conn.close();
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedQueryParamCoercionTypeError() {
    //     connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.prepare(statement("SELECT * FROM immutable WHERE id=", ""), ctx.asyncAssertSuccess(ps -> {
    //             ps.execute(Tuple.of("1"), ctx.asyncAssertFailure(error -> {
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedQueryParamCoercionQuantityError() {
    //     connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.prepare(statement("SELECT * FROM immutable WHERE id=", ""), ctx.asyncAssertSuccess(ps -> {
    //             ps.execute(Tuple.of(1, 2), ctx.asyncAssertFailure(error -> {
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedUpdate() {
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery("INSERT INTO mutable (id, val) VALUES (2, 'Whatever')", ctx.asyncAssertSuccess(r1 -> {
    //             ctx.assertEquals(1, r1.rowCount());
    //             conn.preparedQuery("UPDATE mutable SET val = 'Rocks!' WHERE id = 2", ctx.asyncAssertSuccess(res1 -> {
    //                 ctx.assertEquals(1, res1.rowCount());
    //                 conn.preparedQuery("SELECT val FROM mutable WHERE id = 2", ctx.asyncAssertSuccess(res2 -> {
    //                     ctx.assertEquals("Rocks!", res2.iterator().next().getValue(0));
    //                     conn.close();
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedUpdateWithParams() {
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery("INSERT INTO mutable (id, val) VALUES (2, 'Whatever')", ctx.asyncAssertSuccess(r1 -> {
    //             ctx.assertEquals(1, r1.rowCount());
    //             conn.preparedQuery(statement("UPDATE mutable SET val = ", " WHERE id = ", ""), Tuple.of("Rocks Again!!", 2), ctx.asyncAssertSuccess(res1 -> {
    //                 ctx.assertEquals(1, res1.rowCount());
    //                 conn.preparedQuery(statement("SELECT val FROM mutable WHERE id = ", ""), Tuple.of(2), ctx.asyncAssertSuccess(res2 -> {
    //                     ctx.assertEquals("Rocks Again!!", res2.iterator().next().getValue(0));
    //                     conn.close();
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testPreparedUpdateWithNullParams() {
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.preparedQuery(
    //             statement("INSERT INTO mutable (val, id) VALUES (", ",", ")"), Tuple.of(null, 1),
    //             ctx.asyncAssertFailure(error -> {
    //             })
    //         );
    //     }));
    // }

    // // Need to test partial query close or abortion ?
    // @Test
    // void testQueryCursor() {
    //     Async async = ctx.async();
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(begin -> {
    //             conn.prepare(statement("SELECT * FROM immutable WHERE id="," OR id=", " OR id=", " OR id=", " OR id=", " OR id=",""), ctx.asyncAssertSuccess(ps -> {
    //                 Cursor query = ps.cursor(Tuple.of(1, 8, 4, 11, 2, 9));
    //                 query.read(4, ctx.asyncAssertSuccess(result -> {
    //                     ctx.assertNotNull(result.columnsNames());
    //                     ctx.assertEquals(4, result.size());
    //                     ctx.assertTrue(query.hasMore());
    //                     query.read(4, ctx.asyncAssertSuccess(result2 -> {
    //                         ctx.assertNotNull(result.columnsNames());
    //                         ctx.assertEquals(4, result.size());
    //                         ctx.assertFalse(query.hasMore());
    //                         async.complete();
    //                     }));
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testQueryCloseCursor() {
    //     Async async = ctx.async();
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(begin -> {
    //             conn.prepare(statement("SELECT * FROM immutable WHERE id="," OR id=", " OR id=", " OR id=", " OR id=", " OR id=",""), ctx.asyncAssertSuccess(ps -> {
    //                 Cursor query = ps.cursor(Tuple.of(1, 8, 4, 11, 2, 9));
    //                 query.read(4, ctx.asyncAssertSuccess(results -> {
    //                     ctx.assertEquals(4, results.size());
    //                     query.close(ctx.asyncAssertSuccess(v1 -> {
    //                         ps.close(ctx.asyncAssertSuccess(v2 -> {
    //                             async.complete();
    //                         }));
    //                     }));
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testQueryStreamCloseCursor() {
    //     Async async = ctx.async();
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(begin -> {
    //             conn.prepare(statement("SELECT * FROM immutable WHERE id="," OR id=", " OR id=", " OR id=", " OR id=", " OR id=",""), ctx.asyncAssertSuccess(ps -> {
    //                 Cursor stream = ps.cursor(Tuple.of(1, 8, 4, 11, 2, 9));
    //                 stream.read(4, ctx.asyncAssertSuccess(result -> {
    //                     ctx.assertEquals(4, result.size());
    //                     stream.close(ctx.asyncAssertSuccess(v1 -> {
    //                         ps.close(ctx.asyncAssertSuccess(v2 -> {
    //                             async.complete();
    //                         }));
    //                     }));
    //                 }));
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testStreamQuery() {
    //     Async async = ctx.async();
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(begin -> {
    //             conn.prepare("SELECT * FROM immutable", ctx.asyncAssertSuccess(ps -> {
    //                 RowStream!(Row) stream = ps.createStream(4, Tuple.tuple());
    //                 List!(Tuple) rows = new ArrayList<>();
    //                 AtomicInteger ended = new AtomicInteger();
    //                 stream.endHandler(v -> {
    //                     ctx.assertEquals(0, ended.getAndIncrement());
    //                     ctx.assertEquals(12, rows.size());
    //                     async.complete();
    //                 });
    //                 stream.handler(tuple -> {
    //                     ctx.assertEquals(0, ended.get());
    //                     rows.add(tuple);
    //                 });
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testStreamQueryPauseInBatch() {
    //     testStreamQueryPauseInBatch(ctx, Runnable::run);
    // }

    // @Test
    // void testStreamQueryPauseInBatchFromAnotherThread() {
    //     testStreamQueryPauseInBatch(ctx, t -> new Thread(t).start());
    // }

    // private void testStreamQueryPauseInBatch(, Executor executor) {
    //     Async async = ctx.async();
    //     connector.connect(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(begin -> {
    //             conn.prepare("SELECT * FROM immutable", ctx.asyncAssertSuccess(ps -> {
    //                 RowStream!(Row) stream = ps.createStream(4, Tuple.tuple());
    //                 List!(Tuple) rows = Collections.synchronizedList(new ArrayList<>());
    //                 AtomicInteger ended = new AtomicInteger();
    //                 executor.execute(() -> {
    //                     stream.endHandler(v -> {
    //                         ctx.assertEquals(0, ended.getAndIncrement());
    //                         ctx.assertEquals(12, rows.size());
    //                         async.complete();
    //                     });
    //                     stream.handler(tuple -> {
    //                         rows.add(tuple);
    //                         if (rows.size() == 2) {
    //                             stream.pause();
    //                             executor.execute(() -> {
    //                                 vertx.setTimer(100, v -> {
    //                                     executor.execute(stream::resume);
    //                                 });
    //                             });
    //                         }
    //                     });
    //                 });
    //             }));
    //         }));
    //     }));
    // }

}
