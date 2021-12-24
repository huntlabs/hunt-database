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
module hunt.database.driver.postgresql.impl.codec.ExtendedBatchQueryCommandCodec;

import hunt.database.driver.postgresql.impl.codec.ExtendedQueryCommandBaseCodec;
import hunt.database.driver.postgresql.impl.codec.Parse;
import hunt.database.driver.postgresql.impl.codec.PgEncoder;
import hunt.database.driver.postgresql.impl.codec.PgPreparedStatement;

import hunt.database.base.Tuple;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;

import hunt.collection.List;
import hunt.logging;

import std.variant;

/**
*/
class ExtendedBatchQueryCommandCodec(R) : ExtendedQueryCommandBaseCodec!(R,
        ExtendedBatchQueryCommand!(R)) {

    this(ExtendedBatchQueryCommand!(R) cmd) {
        super(cmd);
    }

    override void encode(PgEncoder encoder) {
        if (cmd.isSuspended()) {
            encoder.writeExecute(cmd.cursorId(), cmd.fetch());
            encoder.writeSync();
        } else {
            PgPreparedStatement ps = cast(PgPreparedStatement) cmd.preparedStatement();
            version(HUNT_DB_DEBUG) tracef("batch sql: %s", ps.sql());
            if (ps.bind.statement == 0) {
                encoder.writeParse(new Parse(ps.sql()));
            }
            if (cmd.params().isEmpty()) {
                // We set suspended to false as we won't get a command complete command back from Postgres
                this.result = false;
            } else {
                foreach (Tuple param; cmd.params()) {
                    encoder.writeBind(ps.bind, cmd.cursorId(), cast(List!(Variant)) param);
                    encoder.writeExecute(cmd.cursorId(), cmd.fetch());
                }
            }
            encoder.writeSync();
        }
    }
}
