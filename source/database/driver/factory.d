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


    SqlBuilder createBuilder(Database db)
    {
		version(USE_POSTGRESQL){
            if(_config.isPgsql)
			    return new PostgresqlSqlBuilder(db);
		}
		 version(USE_SQLITE){
            if(_config.isSqlite)
			    return new SqliteBuilder(db);
		}
        version(USE_MYSQL) {
            if(_config.isMysql)
			    return new MySqlBuilder(db);
        }
        throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
    }
    

}
