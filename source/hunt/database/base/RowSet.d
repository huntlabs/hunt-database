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

module hunt.database.base.RowSet;

import hunt.database.base.AsyncResult;
import hunt.database.base.Row;
import hunt.database.base.RowIterator;
import hunt.database.base.SqlResult;

import hunt.util.Common;

alias RowSetHandler = AsyncResultHandler!RowSet;
alias RowSetAsyncResult = AsyncResult!RowSet;


/**
 * A set of rows.
 */
interface RowSet : Iterable!(Row), SqlResult!(RowSet) {

    RowIterator iterator();

    // override RowSet next();
}
