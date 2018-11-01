module hunt.database.driver.Factory;

import hunt.database;

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

    
    QueryBuilder createQueryBuilder(Database db)
    {
        version(USE_POSTGRESQL){
            if(_config.isPgsql)
			    return new QueryBuilder(db);
		}
		 version(USE_SQLITE){
            if(_config.isSqlite)
			    return new QueryBuilder(db);
		}
        version(USE_MYSQL) {
            if(_config.isMysql)
			    return new QueryBuilder(db);
        }
        throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
    }

}
