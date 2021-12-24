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

module hunt.database.base.Cursor;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.RowSet;

import hunt.logging;



/**
 * A cursor that reads progressively rows from the database, it is useful for reading very large result sets.
 */
interface Cursor {

    /**
     * Read rows from the cursor, the result is provided asynchronously to the {@code handler}.
     *
     * @param count the amount of rows to read
     * @param handler the handler for the result
     */
    void read(int count, RowSetHandler handler);

    /**
     * Returns {@code true} when the cursor has results in progress and the {@link #read} should be called to retrieve
     * them.
     *
     * @return whether the cursor has more results,
     */
    bool hasMore();

    /**
     * Release the cursor.
     * <p/>
     * It should be called for prepared queries executed with a fetch size.
     */
    final void close() {
        close((ar) {
            warning("do nothing...");
        });
    }

    /**
     * Like {@link #close()} but with a {@code completionHandler} called when the cursor has been released.
     */
    void close(AsyncVoidHandler completionHandler);

}
