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

module test.pgclient.PgTestBase;

import hunt.database.base;
import hunt.database.driver.postgresql;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;


/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */

abstract class PgTestBase {

    // @ClassRule
    // static PgRule rule = new PgRule();

    protected PgConnectOptions options;

    void setup() {
        options = new PgConnectOptions();
        options.setHost("10.1.11.44");
        // options.setHost("10.1.222.120");
        options.setPort(5432);
        options.setUser("postgres");
        options.setPassword("123456");
        options.setDatabase("postgres");
    }

    static void deleteFromTestTable(SqlClient client, Action completionHandler) {
        client.query(
            "DELETE FROM Test",
            (result) { 
                trace(typeid(result));
                assert(result.succeeded());
                if(completionHandler !is null)
                    completionHandler();
            });
    }

    static void insertIntoTestTable(SqlClient client, int amount, Action completionHandler) {
        shared int count;
        for (int i = 0;i < 10;i++) {
            client.query("INSERT INTO Test (id, val) VALUES (" ~ i.to!string()
                ~ ", 'Whatever-" ~ i.to!string() ~ "')", 
                (r) {
                    // ctx.assertEquals(1, r1.rowCount());
                    
                    trace(typeid(r));
                    assert(r.succeeded());

                    RowSet r1 = r.result();
                    assert(r1.rowCount() == 1);

                    int c = atomicOp!"+="(count, 1);
                    trace("c=%d, amount=%d", c, amount);
                    if (c == amount) {
                        if(completionHandler !is null)
                            completionHandler();
                    }
                }
            );
        }
    }
}
