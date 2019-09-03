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

module hunt.database.mysql.impl.codec.MySQLPreparedStatement;

import hunt.database.base.impl.ParamDesc;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.RowDesc;

import hunt.collection.List;

class MySQLPreparedStatement : PreparedStatement {

    long statementId;
    string _sql;
    MySQLParamDesc _paramDesc;
    MySQLRowDesc _rowDesc;

    bool isCursorOpen;

    this(string sql, long statementId, MySQLParamDesc paramDesc, MySQLRowDesc rowDesc) {
        this.statementId = statementId;
        this._paramDesc = paramDesc;
        this._rowDesc = rowDesc;
        this._sql = sql;
    }

    override
    ParamDesc paramDesc() {
        return _paramDesc;
    }

    override
    RowDesc rowDesc() {
        return _rowDesc;
    }

    override
    string sql() {
        return _sql;
    }

    override
    string prepare(List!(Object) values) {
        return paramDesc.prepare(values);
    }
}
