module database.driver.factory;

import database;

 import database.option;

interface IFactory
{

}

class SqlFactory : IFactory
{
    DatabaseOption _config;
    this(DatabaseOption config)
    {
        _config = config;
    }

    //	bool isMysql()
//	bool isPgsql()
//	bool isSqlite()

    SqlBuilder createBuilder()
    {
		version(USE_POSTGRESQL){
            if(_config.isPgsql)
			    return new PostgresqlSqlBuilder();
		}
		 version(USE_SQLITE){
            if(_config.isSqlite)
			    return new SqliteBuilder();
		}
        version(USE_MYSQL) {
            if(_config.isMysql)
			    return new MySqlBuilder();
        }
        throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
    }
    SqlBuilder createMySqlBuilder()
    {
        return new MySqlBuilder();
    }
    SqlBuilder createPostgresqlSqlBuilder()
    {
        return new PostgresqlSqlBuilder();
    }
    SqlBuilder createSqliteBuilder()
    {
        return new SqliteBuilder();
    }
}
