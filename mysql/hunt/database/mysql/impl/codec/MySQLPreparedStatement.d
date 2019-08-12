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

module hunt.database.mysql.impl.codec;

import hunt.database.base.impl.ParamDesc;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.RowDesc;

import java.util.List;

class MySQLPreparedStatement implements PreparedStatement {

  final long statementId;
  final String sql;
  final MySQLParamDesc paramDesc;
  final MySQLRowDesc rowDesc;

  boolean isCursorOpen;

  MySQLPreparedStatement(String sql, long statementId, MySQLParamDesc paramDesc, MySQLRowDesc rowDesc) {
    this.statementId = statementId;
    this.paramDesc = paramDesc;
    this.rowDesc = rowDesc;
    this.sql = sql;
  }

  override
  ParamDesc paramDesc() {
    return paramDesc;
  }

  override
  RowDesc rowDesc() {
    return rowDesc;
  }

  override
  String sql() {
    return sql;
  }

  override
  String prepare(List!(Object) values) {
    return paramDesc.prepare(values);
  }
}
