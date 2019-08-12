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

module hunt.database.base.impl.command.ExtendedQueryCommandBase;

import hunt.database.base.Row;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.QueryResultHandler;

import java.util.stream.Collector;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class ExtendedQueryCommandBase!(R) extends QueryCommandBase!(R) {

  protected final PreparedStatement ps;
  protected final int fetch;
  protected final String cursorId;
  protected final boolean suspended;
  private final boolean singleton;

  ExtendedQueryCommandBase(PreparedStatement ps,
                           int fetch,
                           String cursorId,
                           boolean suspended,
                           boolean singleton,
                           Collector<Row, ?, R> collector,
                           QueryResultHandler!(R) resultHandler) {
    super(collector, resultHandler);
    this.ps = ps;
    this.fetch = fetch;
    this.cursorId = cursorId;
    this.suspended = suspended;
    this.singleton = singleton;
  }

  PreparedStatement preparedStatement() {
    return ps;
  }

  int fetch() {
    return fetch;
  }

  String cursorId() {
    return cursorId;
  }

  boolean isSuspended() {
    return suspended;
  }

  boolean isSingleton() {
    return singleton;
  }

  override
  String sql() {
    return ps.sql();
  }
}
