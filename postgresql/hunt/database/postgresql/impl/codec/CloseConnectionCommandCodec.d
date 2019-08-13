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
module hunt.database.postgresql.impl.codec.CloseConnectionCommandCodec;

import hunt.database.postgresql.impl.codec.PgEncoder;
import hunt.database.base.impl.command.CloseConnectionCommand;

import std.concurrency : initOnce;

class CloseConnectionCommandCodec : PgCommandCodec!(Void, CloseConnectionCommand) {

    static CloseConnectionCommandCodec INSTANCE() {
        __gshared CloseConnectionCommandCodec inst;
        return initOnce!inst(new CloseConnectionCommandCodec());
    }

    private this() {
        super(CloseConnectionCommand.INSTANCE());
    }

    override
    void encode(PgEncoder encoder) {
        encoder.writeTerminate();
    }

}
