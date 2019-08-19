/*
 * Copyright (c) 2011-2017 Contributors to the Eclipse Foundation
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
 * which is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
 */
module hunt.database.base.AsyncResult;

import hunt.database.base.Common;

import hunt.Exceptions;
import hunt.Functions;

alias AsyncResultHandler(T) = EventHandler!(AsyncResult!T);

/**
 * Encapsulates the result of an asynchronous operation.
 * <p>
 * Many operations in Vert.x APIs provide results back by passing an instance of this in a {@link hunt.net.Handler}.
 * <p>
 * The result can either have failed or succeeded.
 * <p>
 * If it failed then the cause of the failure is available with {@link #cause}.
 * <p>
 * If it succeeded then the actual result is available with {@link #result}
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface AsyncResult(T) {

    /**
     * The result of the operation. This will be null if the operation failed.
     *
     * @return the result or null if the operation failed.
     */
    T result();

    /**
     * A Throwable describing failure. This will be null if the operation succeeded.
     *
     * @return the cause or null if the operation succeeded.
     */
    Throwable cause();

    /**
     * Did it succeed?
     *
     * @return true if it succeded or false otherwise
     */
    bool succeeded();

    /**
     * Did it fail?
     *
     * @return true if it failed or false otherwise
     */
    bool failed();

    /**
     * Apply a {@code mapper} function on this async result.<p>
     *
     * The {@code mapper} is called with the completed value and this mapper returns a value. This value will complete the result returned by this method call.<p>
     *
     * When this async result is failed, the failure will be propagated to the returned async result and the {@code mapper} will not be called.
     *
     * @param mapper the mapper function
     * @return the mapped async result
     */
    final AsyncResult!(U) map(U)(Function!(T, U) mapper) {
        if (mapper is null) {
            throw new NullPointerException();
        }
        return new class AsyncResult!(U) {
            override U result() {
                if (succeeded()) {
                    return mapper.apply(this.outer.result());
                } else {
                    return null;
                }
            }

            override Throwable cause() {
                return this.outer.cause();
            }

            override bool succeeded() {
                return this.outer.succeeded();
            }

            override bool failed() {
                return this.outer.failed();
            }
        };
    }

    /**
     * Map the result of this async result to a specific {@code value}.<p>
     *
     * When this async result succeeds, this {@code value} will succeeed the async result returned by this method call.<p>
     *
     * When this async result fails, the failure will be propagated to the returned async result.
     *
     * @param value the value that eventually completes the mapped async result
     * @return the mapped async result
     */
    final AsyncResult!(V) map(V)(V value) {
        return map((t) => value);
    }

    /**
     * Map the result of this async result to {@code null}.<p>
     *
     * This is a convenience for {@code asyncResult.map((T) null)} or {@code asyncResult.map((Void) null)}.<p>
     *
     * When this async result succeeds, {@code null} will succeeed the async result returned by this method call.<p>
     *
     * When this async result fails, the failure will be propagated to the returned async result.
     *
     * @return the mapped async result
     */
    final AsyncResult!(V) mapEmpty(V)() {
        return map(V.init);
    }

    /**
     * Apply a {@code mapper} function on this async result.<p>
     *
     * The {@code mapper} is called with the failure and this mapper returns a value. This value will complete the result returned by this method call.<p>
     *
     * When this async result is succeeded, the value will be propagated to the returned async result and the {@code mapper} will not be called.
     *
     * @param mapper the mapper function
     * @return the mapped async result
     */
    final AsyncResult!(T) otherwise(Function!(Throwable, T) mapper) {
        if (mapper is null) {
            throw new NullPointerException();
        }
        return new class AsyncResult!(T) {
            override T result() {
                if (this.outer.succeeded()) {
                    return this.outer.result();
                } else if (this.outer.failed()) {
                    return mapper(this.outer.cause());
                } else {
                    return null;
                }
            }

            override Throwable cause() {
                return null;
            }

            override bool succeeded() {
                return this.outer.succeeded() || this.outer.failed();
            }

            override bool failed() {
                return false;
            }
        };
    }

    /**
     * Map the failure of this async result to a specific {@code value}.<p>
     *
     * When this async result fails, this {@code value} will succeeed the async result returned by this method call.<p>
     *
     * When this async succeeds, the result will be propagated to the returned async result.
     *
     * @param value the value that eventually completes the mapped async result
     * @return the mapped async result
     */
    final AsyncResult!(T) otherwise(T value) {
        return otherwise((err) => value);
    }

    /**
     * Map the failure of this async result to {@code null}.<p>
     *
     * This is a convenience for {@code asyncResult.otherwise((T) null)}.<p>
     *
     * When this async result fails, the {@code null} will succeeed the async result returned by this method call.<p>
     *
     * When this async succeeds, the result will be propagated to the returned async result.
     *
     * @return the mapped async result
     */
    final AsyncResult!(T) otherwiseEmpty() {
        return otherwise((err) => T.init);
    }

}

AsyncResult!T succeededResult(T)(T v) {
    return new class AsyncResult!(T) {
        override T result() {
            return v;
        }

        override Throwable cause() {
            return null;
        }

        override bool succeeded() {
            return true;
        }

        override bool failed() {
            return false;
        }
    };
}


AsyncResult!T failedResult(T)(Throwable t) {
    return new class AsyncResult!(T) {
        override T result() {
            return T.init;
        }

        override Throwable cause() {
            return t;
        }

        override bool succeeded() {
            return false;
        }

        override bool failed() {
            return true;
        }
    };
}