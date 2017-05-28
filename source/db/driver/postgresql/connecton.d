module db.driver.postgresql.connection;

import db.driver.connection;
import db.derver.postgresql.statement;

class PostgresqlConnection : Connection
{
    override Statemente query(string sql)
    {
        return null;
    }

    override int execute(string sql)
    {
        return 0;
    }
}