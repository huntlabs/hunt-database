module hunt.database.mysql.MySQLException;

/**
 * A {@link RuntimeException} signals that an error occurred.
 */
class MySQLException : RuntimeException {
  private final int errorCode;
  private final String sqlState;

  MySQLException(String message, int errorCode, String sqlState) {
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
  String getSqlState() {
    return sqlState;
  }

  /**
   * Get the error message in the error message sent from MySQL server.
   *
   * @return the error message
   */
  override
  String getMessage() {
    return super.getMessage();
  }
}
