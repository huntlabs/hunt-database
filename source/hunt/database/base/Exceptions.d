module hunt.database.base.Exceptions;

import hunt.Exceptions;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
class NoStackTraceThrowable : Throwable {

    this(string message) {
        super(message);
    }
}

class DatabaseException : Exception {
    mixin BasicExceptionCtors;
}