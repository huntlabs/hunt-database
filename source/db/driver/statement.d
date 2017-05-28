module db.statement;

public import db.row;

abstract class AbstractStatement
{
    this(string sql)
    {
        //
    }
    
    // return result set
    Row[] fetch();
}
