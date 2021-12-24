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

module hunt.database.base.impl.command.PrepareStatementCommand;

import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.PreparedStatement;
import hunt.logging;

/**
 * 
 */
class PrepareStatementCommand : CommandBase!(PreparedStatement) {

    private string _sql;
    long _statement; // 0 means unamed statement otherwise CString
    Object cached;

    this(string sql) {
        version(HUNT_DB_DEBUG) info(sql);
        this._sql = sql;
    }

    string sql() {
        return _sql;
    }

    long statement() {
        return _statement;
    }

}
