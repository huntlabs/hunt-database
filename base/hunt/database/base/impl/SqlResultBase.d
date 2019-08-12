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

module hunt.database.base.impl.SqlResultBase;

import hunt.database.base.SqlResult;

import java.util.List;

abstract class SqlResultBase!(T, R extends SqlResultBase!(T, R)) implements SqlResult!(T) {

  int updated;
  List!(String) columnNames;
  int size;
  R next;

  override
  List!(String) columnsNames() {
    return columnNames;
  }

  override
  int rowCount() {
    return updated;
  }

  override
  int size() {
    return size;
  }

  override
  R next() {
    return next;
  }
}
