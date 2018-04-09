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

    QueryBuilder createQueryBuilder()
    {
        switch(this._driver)
        {
            default:
            throw new DatabaseException("Unknow database driver" ~ this._driver);
            case "mysql":
            return new MysqlQueryBuilder();
            case "postgresql":
            return new PostgresqlQueryBuilder();
            case "sqlite":
            return new SqliteQueryBuilder();
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
