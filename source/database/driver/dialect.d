module database.driver.dialect;

import database;

interface Dialect
{
    string closeQuote(); 
    string  openQuote();
	Variant fromSqlValue(DlangDataType fieldType,Variant fieldValue);
    string toSqlValueImpl(DlangDataType type,Variant value);
    string toSqlValue(T)(T val)
    {
        Variant value = val;
        DlangDataType type = getDlangDataType!T(val);
        return toSqlValueImpl(type, value);
    }

}
