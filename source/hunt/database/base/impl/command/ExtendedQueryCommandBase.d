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

import hunt.database.base.impl.command.QueryCommandBase;

import hunt.database.base.Row;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.QueryResultHandler;

// import java.util.stream.Collector;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class ExtendedQueryCommandBase(R) : QueryCommandBase!(R) {

    protected PreparedStatement ps;
    protected int _fetch;
    protected string _cursorId;
    protected bool suspended;
    private bool singleton;

    this(PreparedStatement ps,
                int fetch,
                string cursorId,
                bool suspended,
                bool singleton,
                QueryResultHandler!(R) resultHandler) {
        super(resultHandler); 
        this.ps = ps;
        this._fetch = fetch;
        this._cursorId = cursorId;
        this.suspended = suspended;
        this.singleton = singleton;
    }

    PreparedStatement preparedStatement() {
        return ps;
    }

    int fetch() {
        return _fetch;
    }

    string cursorId() {
        return _cursorId;
    }

    bool isSuspended() {
        return suspended;
    }

    bool isSingleton() {
        return singleton;
    }

    override
    string sql() {
        return ps.sql();
    }
}
