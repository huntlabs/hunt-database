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

module hunt.database.base.impl.command.ExtendedBatchQueryCommand;

import hunt.database.base.Row;
import hunt.database.base.Tuple;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.QueryResultHandler;

import java.util.List;
import java.util.stream.Collector;

class ExtendedBatchQueryCommand!(T) extends ExtendedQueryCommandBase!(T) {

  private final List!(Tuple) params;

  ExtendedBatchQueryCommand(PreparedStatement ps,
                            List!(Tuple) params,
                            boolean singleton,
                            Collector<Row, ?, T> collector,
                            QueryResultHandler!(T) resultHandler) {
    this(ps, params, 0, null, false, singleton, collector, resultHandler);
  }

  private ExtendedBatchQueryCommand(PreparedStatement ps,
                            List!(Tuple) params,
                            int fetch,
                            String cursorId,
                            boolean suspended,
                            boolean singleton,
                            Collector<Row, ?, T> collector,
                            QueryResultHandler!(T) resultHandler) {
    super(ps, fetch, cursorId, suspended, singleton, collector, resultHandler);
    this.params = params;
  }

  List!(Tuple) params() {
    return params;
  }

}
