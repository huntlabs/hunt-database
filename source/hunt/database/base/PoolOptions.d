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

module hunt.database.base.PoolOptions;

import hunt.Exceptions;

import core.time;

/**
 * The options for configuring a connection pool.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PoolOptions {

    /**
     * The default maximum number of connections a client will pool = 4
     */
    enum int DEFAULT_MAX_SIZE = 4;

    /**
     * Default max wait queue size = -1 (unbounded)
     */
    enum int DEFAULT_MAX_WAIT_QUEUE_SIZE = -1;

    private int maxSize = DEFAULT_MAX_SIZE;
    private int maxWaitQueueSize = DEFAULT_MAX_WAIT_QUEUE_SIZE;

    private Duration _awaittingTimeout = 10.seconds;

    this() {
    }

    this(PoolOptions other) {
        maxSize = other.maxSize;
        maxWaitQueueSize = other.maxWaitQueueSize;
        awaittingTimeout = other.awaittingTimeout;
    }

    Duration awaittingTimeout() {
        return _awaittingTimeout;
    }

    PoolOptions awaittingTimeout(Duration value) {
        _awaittingTimeout = value;
        return this;
    }

    /**
     * @return  the maximum pool size
     */
    int getMaxSize() {
        return maxSize;
    }

    /**
     * Set the maximum pool size
     *
     * @param maxSize  the maximum pool size
     * @return a reference to this, so the API can be used fluently
     */
    PoolOptions setMaxSize(int maxSize) {
        if (maxSize < 0) {
            throw new IllegalArgumentException("Max size cannot be negative");
        }
        this.maxSize = maxSize;
        return this;
    }

    /**
     * @return the maximum wait queue size
     */
    int getMaxWaitQueueSize() {
        return maxWaitQueueSize;
    }

    /**
     * Set the maximum connection request allowed in the wait queue, any requests beyond the max size will result in
     * an failure.  If the value is set to a negative number then the queue will be unbounded.
     *
     * @param maxWaitQueueSize the maximum number of waiting requests
     * @return a reference to this, so the API can be used fluently
     */
    PoolOptions setMaxWaitQueueSize(int maxWaitQueueSize) {
        this.maxWaitQueueSize = maxWaitQueueSize;
        return this;
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     PoolOptionsConverter.toJson(this, json);
    //     return json;
    // }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        PoolOptions that = cast(PoolOptions) o;
        if(that is null)
            return false;

        if (maxSize != that.maxSize) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + maxSize;
        return result;
    }
}
