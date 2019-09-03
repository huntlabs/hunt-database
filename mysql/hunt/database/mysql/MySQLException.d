module hunt.database.mysql.MySQLException;

import hunt.database.base.Exceptions;

/**
 * A {@link RuntimeException} signals that an error occurred.
 */
class MySQLException : DatabaseException {
    private int errorCode;
    private string sqlState;

    this(string message, int errorCode, string sqlState) {
        super(message);
        this.errorCode = errorCode;
        this.sqlState = sqlState;
    }

    /**
     * Get the error code in the error message sent from MySQL server.
     *
     * @return the error code
     */
    int getErrorCode() {
        return errorCode;
    }

    /**
     * Get the SQL state in the error message sent from MySQL server.
     *
     * @return the SQL state
     */
    string getSqlState() {
        return sqlState;
    }

    /**
     * Get the error message in the error message sent from MySQL server.
     *
     * @return the error message
     */
    string getMessage() {
        return cast(string)super.message();
    }
}
