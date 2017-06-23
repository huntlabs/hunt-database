module db.driver.sqlite.binding;

version(USE_SQLITE):
auto fromSQLType(uint type){return typeid(string);}
public import etc.c.sqlite3;


