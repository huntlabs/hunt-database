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

module hunt.database.base.impl.command.SimpleQueryCommand;

import hunt.database.base.Row;
import hunt.database.base.impl.QueryResultHandler;

// import java.util.stream.Collector;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */

class SimpleQueryCommand(T) : QueryCommandBase!(T) {

    private string _sql;
    private bool _singleton;

    this(string sql,
            bool singleton,
            // Collector<Row, ?, T> collector,
            QueryResultHandler!(T) resultHandler) {
        super(collector, resultHandler);
        this._sql = sql;
        this._singleton = singleton;
    }

    bool isSingleton() {
        return _singleton;
    }

    override
    string sql() {
        return _sql;
    }

}
