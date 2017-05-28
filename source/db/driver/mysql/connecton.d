module db.driver.mysql.connection;

import db.connection;
import db.derver.mysql.statement;

class MysqlConnection : Connection
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