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

module hunt.database.base.RowStream;

import hunt.database.base.AsyncResult;
// import io.vertx.core.streams.ReadStream;

import hunt.database.base.Common;


/**
 * A row oriented stream.
 */
interface RowStream(T) { // : ReadStream!(T)

    RowStream!(T) exceptionHandler(ExceptionHandler handler);

    RowStream!(T) handler(EventHandler!(T) handler);

    RowStream!(T) pause();

    RowStream!(T) resume();

    RowStream!(T) endHandler(VoidHandler endHandler);

    /**
     * Close the stream and release the resources.
     */
    void close();

    /**
     * Close the stream and release the resources.
     *
     * @param completionHandler the completion handler for this operation
     */
    void close(VoidHandler completionHandler);

}
