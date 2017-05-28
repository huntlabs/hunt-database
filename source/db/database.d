
module db.database;

import db.driver.statement;
import db.driver.connection;

class Database
{
    this(string uri)
    {
        //
    }

    bool beginTransaction()
    {
        //
    }

    bool commit()
    {
        //
    }

    int errorCode()
    {
        //
    }

    int errorInfo()
    {
        //
    }

    int execute(string sql)
    {
        //
    }

    Statement query(string sql)
    {
        //
    }

    private
    {
        Connection _conn;
        Statement _stmt;
    }
}
