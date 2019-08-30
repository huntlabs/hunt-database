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
module test.SimpleQueryTestBase;

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

abstract class SimpleQueryTestBase : QueryTestBase {


    @Test
    void testQuery() {
        connect((SqlConnection conn) {
            conn.query("SELECT id, message from immutable", (AsyncResult!RowSet ar)  {
                if(ar.succeeded()) {
                    RowSet result = ar.result();

                    //TODO we need to figure how to handle PgResult#rowCount() method in common API,
                    // MySQL returns affected rows as 0 for SELECT query but Postgres returns queried amount
                    assert(12 == result.rowCount()); // this line does not pass in MySQL but passes in PG                    
                    assert(12 == result.size());

                    Tuple row = result.iterator().front();
                    assert(1 == row.getInteger(0));
                    assert("fortune: No such file or directory" == row.getString(1));

                } else {
                    warning(ar.cause().msg);
                }
            });
        });
    }

    @Test
    void testQueryError() {
        connect((SqlConnection conn) {
            conn.query("SELECT whatever from DOES_NOT_EXIST", (AsyncResult!RowSet ar)  {
                assert(ar.failed);
                warning(ar.cause().msg);
            });
        });
    }

    @Test
    void testInsert() {
        connector((SqlConnection conn) {
            conn.query("INSERT INTO mutable (id, val) VALUES (1, 'Whatever');", 
                (AsyncResult!RowSet ar)  {
                    trace("running here");
                    if(ar.succeeded()) {
                        RowSet result = ar.result();
                        assert(1 == result.rowCount());
                    } else {
                        warning(ar.cause().msg);
                    }
                }
            );
        });
    }

    @Test
    void testUpdate() {
        connector((SqlConnection conn) {
            conn.query("INSERT INTO mutable (id, val) VALUES (1, 'Whatever')", (AsyncResult!RowSet ar1)  {
                trace("running here");
                if(ar1.succeeded()) {
                    RowSet r1 = ar1.result();
                    assert(1 == r1.rowCount());

                    conn.query("UPDATE mutable SET val = 'newValue' WHERE id = 1", (AsyncResult!RowSet ar2)  {
                        trace("running here");
                        if(ar2.succeeded()) {
                            RowSet r2 = ar2.result();
                            assert(1 == r2.rowCount());
                        } else {
                            warning(ar2.cause().msg);
                        }
                    });
                    
                } else {
                    warning(ar1.cause().msg);
                }
            });
        });
    }

    @Test
    void testDelete() {
        connector((SqlConnection conn) {
            insertIntoTestTable(conn, 10, () {
                conn.query("DELETE FROM mutable where id = 6", (AsyncResult!RowSet ar)  {
                    trace("running here");
                    if(ar.succeeded()) {
                        RowSet result = ar.result();
                        assert(1 == result.rowCount());
                    } else {
                        warning(ar.cause().msg);
                    }
                });
            });
        });
    }

}
