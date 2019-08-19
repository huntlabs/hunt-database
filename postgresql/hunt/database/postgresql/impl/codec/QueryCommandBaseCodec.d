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
module hunt.database.postgresql.impl.codec.QueryCommandBaseCodec;

import hunt.database.postgresql.impl.codec.RowResultDecoder;
import hunt.database.postgresql.impl.codec.PgCommandCodec;

import hunt.database.base.Row;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.command.QueryCommandBase;

// import java.util.stream.Collector;

abstract class QueryCommandBaseCodec(T, C) : PgCommandCodec!(bool, C) { // C extends QueryCommandBase!(T)

    // RowResultDecoder<?, T> decoder;
    AbstractRowResultDecoder!T decoder;

    this(C cmd) {
        super(cmd);
    }

    override
    void handleCommandComplete(int updated) {
        this.result = false;
        T result;
        int size;
        RowDesc desc;
        if (decoder !is null) {
            result = decoder.complete();
            desc = decoder.desc;
            size = decoder.size();
            decoder.reset();
        } else {
            result = emptyResult(cmd.collector());
            size = 0;
            desc = null;
        }
        cmd.resultHandler().handleResult(updated, size, desc, result);
    }

    override
    void handleErrorResponse(ErrorResponse errorResponse) {
        failure = errorResponse.toException();
    }

    // private static <A, T> T emptyResult(Collector!(Row, A, T) collector) {
    //     return collector.finisher().apply(collector.supplier().get());
    // }
}