module database.factory;

import database.driver.postgresql;
import database.driver.mysql;
import database.driver.sqlite;

class Factory
{
    private
    {
        string _driver;
    }

    this(string driver)
    {
        this._driver = driver;
    }

    SqlBuilder createSqlBuilder()
    {
        switch(this._driver)
        {
            default:
            throw new DatabaseException("Unknow database driver" ~ this._driver);
            case "mysql":
            return new MysqlSqlBuilder();
            case "postgresql":
            return new PostgresqlSqlBuilder();
            case "sqlite":
            return new SqliteSqlBuilder();
        }
    }

    Dialect createDialect()
    {
        switch(this._driver)
        {
            default:
            throw new DatabaseException("Unknow database driver" ~ this._driver);
            case "mysql":
            return new MysqlDialect();
            case "postgresql":
            return new PostgresqlDialect();
            case "sqlite":
            return new SqliteDialect();
        }
    }
}
