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

module hunt.database.base.impl.command.ExtendedQueryCommand;

import hunt.database.base.impl.command.ExtendedQueryCommandBase;

import hunt.database.base.Row;
import hunt.database.base.Tuple;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.QueryResultHandler;

/**
*/
class ExtendedQueryCommand(T) : ExtendedQueryCommandBase!(T) {

    private Tuple _params;

    this(PreparedStatement ps,
            Tuple params,
            bool singleton,
            QueryResultHandler!(T) resultHandler) {
        this(ps, params, 0, null, false, singleton, resultHandler);
    }

    this(PreparedStatement ps,
            Tuple params,
            int fetch,
            string cursorId,
            bool suspended,
            bool singleton,
            QueryResultHandler!(T) resultHandler) {
        super(ps, fetch, cursorId, suspended, singleton, resultHandler);
        this._params = params;
    }

    Tuple params() {
        return _params;
    }

}
