module hunt.database.base.Exceptions;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
class NoStackTraceThrowable : Throwable {

    this(string message) {
        super(message);
    }
}
