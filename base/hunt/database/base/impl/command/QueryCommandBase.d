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

module hunt.database.base.impl.command.QueryCommandBase;

import hunt.database.base.Row;
import hunt.database.base.impl.QueryResultHandler;

// import java.util.stream.Collector;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */

abstract class QueryCommandBase(T) : CommandBase!(Boolean) {

    private QueryResultHandler!(T) resultHandler;
    // private Collector<Row, ?, T> collector;

    this(QueryResultHandler!(T) resultHandler) { // Collector<Row, ?, T> collector, 
        this.resultHandler = resultHandler;
        // this.collector = collector;
    }

    QueryResultHandler!(T) resultHandler() {
        return resultHandler;
    }

    // Collector<Row, ?, T> collector() {
    //     return collector;
    // }

    abstract string sql();

}
