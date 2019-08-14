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
module hunt.database.postgresql.impl.codec.ExtendedQueryCommandBaseCodec;

import hunt.database.postgresql.impl.codec.QueryCommandBaseCodec;
import hunt.database.postgresql.impl.codec.RowResultDecoder;

import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.command.ExtendedQueryCommandBase;

import hunt.Exceptions;

abstract class ExtendedQueryCommandBaseCodec(R, C) : QueryCommandBaseCodec!(R, C) { // extends ExtendedQueryCommandBase!(R)

    this(C cmd) {
        super(cmd);
        // TODO: Tasks pending completion -@zxp at 8/14/2019, 11:47:10 AM
        // 
        implementationMissing(false);
        // decoder = new RowResultDecoder<>(cmd.collector(), cmd.isSingleton(), 
        //     (cast(PgPreparedStatement)cmd.preparedStatement()).rowDesc());
    }

    override
    void handleRowDescription(PgRowDesc rowDescription) {
        implementationMissing(false);
        // decoder = new RowResultDecoder<>(cmd.collector(), cmd.isSingleton(), rowDescription);
    }

    override
    void handleParseComplete() {
        // Response to Parse
    }

    override
    void handlePortalSuspended() {
        R result = decoder.complete();
        RowDesc desc = decoder.desc;
        int size = decoder.size();
        decoder.reset();
        this.result = true;
        cmd.resultHandler().handleResult(0, size, desc, result);
    }

    override
    void handleBindComplete() {
        // Response to Bind
    }
}
