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

module hunt.database.postgresql.impl.codec.PgPreparedStatement;

import hunt.database.postgresql.impl.codec.Bind;
import hunt.database.postgresql.impl.codec.PgColumnDesc;
import hunt.database.postgresql.impl.codec.PgParamDesc;
import hunt.database.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.ParamDesc;

// import hunt.collection.Arrays;
import hunt.collection.List;

class PgPreparedStatement : PreparedStatement {

    private enum PgColumnDesc[] EMPTY_COLUMNS = [];

    string sql;
    Bind bind;
    PgParamDesc paramDesc;
    PgRowDesc rowDesc;

    this(string sql, long statement, PgParamDesc paramDesc, PgRowDesc rowDesc) {

        // Fix to use binary when possible
        if (rowDesc !is null) {
            rowDesc = new PgRowDesc(rowDesc.columns
                .map(c => new PgColumnDesc(
                    c.name,
                    c.relationId,
                    c.relationAttributeNo,
                    c.dataType,
                    c.length,
                    c.typeModifier))
                .array);

                // ,
                //     c.dataType.supportsBinary ? DataFormat.BINARY : DataFormat.TEXT
        }

        this.paramDesc = paramDesc;
        this.rowDesc = rowDesc;
        this.sql = sql;
        this.bind = new Bind(statement, paramDesc !is null ? paramDesc.paramDataTypes() : null, 
            rowDesc !is null ? rowDesc.columns : EMPTY_COLUMNS);
    }

    override
    ParamDesc paramDesc() {
        return paramDesc;
    }

    override
    PgRowDesc rowDesc() {
        return rowDesc;
    }

    override
    string sql() {
        return sql;
    }

    override
    string prepare(List!(Object) values) {
        return paramDesc.prepare(values);
    }
}