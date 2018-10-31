module hunt.database.driver.factory;

import hunt.database;

import hunt.database.option;
import hunt.sql;

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
    
    QueryBuilder createQueryBuilder(Database db)
    {
        version(USE_POSTGRESQL){
            if(_config.isPgsql)
			    return new QueryBuilder(DBType.POSTGRESQL.name);
		}
		 version(USE_SQLITE){
            if(_config.isSqlite)
			    return new QueryBuilder(DBType.SQLITE.name);
		}
        version(USE_MYSQL) {
            if(_config.isMysql)
			    return new QueryBuilder(DBType.MYSQL.name);
        }
        throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
    }

}
