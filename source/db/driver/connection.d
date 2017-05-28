module db.driver.connection;

import db.driver.statement;

abstract class AbstractConnection
{
    this(Statement stmt)
    {
        _stmt = stmt;
    }

    // return affected line quantity
    int execute(string sql);

    // return Statement object
    Statement query(string sql);

    private
    {
        Statement _stmt;
        int _errorCode;
    }
}
