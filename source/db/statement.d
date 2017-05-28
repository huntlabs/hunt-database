module db.statement;

import db.row;

class Statement
{
    this(string sql)
    {
        //
    }
    
    // return result set
    Row[] fetch();
}
