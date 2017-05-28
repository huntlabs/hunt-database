
module db.connection;

import db.driver.connection;
import db.driver.postgresql.connecton;
import db.driver.mysql.connecton;

import db.driver.statement;
import db.driver.postgresql.statement;
import db.driver.mysql.statement;

import std.experimental.logger;

class Connection
{
    this()
    {
        _stmt = new Statement;
    }
    
    private bool initConnection(string driver)
    {
        switch(driver)
        {
            case "postgresql":
                _conn = new PostgresqlConnection(_stmt);
                break;
            case "mysql":
                _conn = new MysqlConnection(_stmt);
                break;
            default:
                errorf("Don't support database driver: %s", driver);
                return false;
                break;
        }

        return true;
    }

    private
    {
        AbstractStatement _stmt;
        AbstractConnection _conn;
    }
}
