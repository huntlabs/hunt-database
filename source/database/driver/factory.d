module database.driver.factory;

import database;

interface IFactory
{

}

class SqlFactory : IFactory
{
    SqlBuilder createBuilder()
    {
		version(USE_POSTGRESQL){
			return new PgSqlBuilder();
		}
		else version(USE_SQLITE){
			return new SqliteBuilder();
		}
        else {
			return new MySqlBuilder();
        }
    }
    SqlBuilder createMySqlBuilder()
    {
        return new MySqlBuilder();
    }
    SqlBuilder createPgSqlBuilder()
    {
        return new PostgresqlSqlBuilder();
    }
    SqlBuilder createSqliteBuilder()
    {
        return new SqliteBuilder();
    }
}
