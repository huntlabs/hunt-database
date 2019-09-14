/*
 * Copyright (C) 2018 Julien Viet
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
module hunt.database.driver.postgresql.impl.codec.SimpleQueryCommandCodec;

import hunt.database.driver.postgresql.impl.codec.QueryCommandBaseCodec;
import hunt.database.driver.postgresql.impl.codec.Query;
import hunt.database.driver.postgresql.impl.codec.PgEncoder;
import hunt.database.driver.postgresql.impl.codec.PgRowDesc;
import hunt.database.driver.postgresql.impl.codec.RowResultDecoder;
import hunt.database.base.impl.RowSetImpl;

import hunt.database.base.impl.command.SimpleQueryCommand;

import hunt.logging.ConsoleLogger;

/**
*/
class SimpleQueryCommandCodec(T) : QueryCommandBaseCodec!(T, SimpleQueryCommand!(T)) {

    this(SimpleQueryCommand!(T) cmd) {
        super(cmd);
    }

    override
    void encode(PgEncoder encoder) {
        version(HUNT_DB_DEBUG) infof("sql statement: %s", cmd.sql());
        encoder.writeQuery(new Query(cmd.sql()));
    }

    override
    void handleRowDescription(PgRowDesc rowDescription) {
        decoder = new RowResultDecoder!(T)(cmd.isSingleton(), rowDescription); // cmd.collector(), 
    }

    override
    void handleParameterStatus(string key, string value) {
        trace(typeof(this).stringof ~ " should handle message ParameterStatus");
    }
}
