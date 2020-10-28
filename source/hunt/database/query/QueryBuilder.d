/*
 * Copyright 2015-2018 HuntLabs.cn.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module hunt.database.query.QueryBuilder;

import hunt.database.query.Common;
import hunt.database.query.Comparison;
import hunt.database.query.Expr;
import hunt.database.query.Expression;


import hunt.database.driver.postgresql.PgUtil;
import hunt.database.driver.mysql.MySQLUtil;

import hunt.sql;
import hunt.Byte;
import hunt.Exceptions;
import hunt.Integer;
import hunt.Long;
import hunt.logging.ConsoleLogger;
import hunt.Double;
import hunt.Float;
import hunt.Short;
import hunt.String;
import hunt.text.StringBuilder;
import hunt.Nullable;


import std.array;
import std.conv;
import std.regex;
import std.string;
import std.variant;

/**
 * 
 */
class QueryBuilder
{

    private DBType _dbType = DBType.MYSQL;

    private QUERY_TYPE _type = QUERY_TYPE.SELECT;
    private string _table;
    private string _tableAlias;
    private string[] _select;
    private JoinExpression[] _join;
    private string _where;
    private string[] _whereAnd;
    private string[] _whereOr;

    private ValueVariant[string] _values;
    private string _having;
    private string[] _groupBy;
    private string[] _orderBy;
    private int _offset;
    private int _limit;
    private Variant[string] _parameters; // TODO: use Variant[string];
    // private Expr _expr;
    private bool _distinct;
    private string _autoIncreaseKey;

    
    this(DBType dbType) {
        _dbType = dbType;
    }

    // @property Expr expr()
    // {
    //     if (_expr is null)
    //         _expr = new Expr();
    //     return _expr;
    // }

    QueryBuilder from(string table, string _alias = null)
    {
        // logDebug("QueryBuilder From : %s , %s ".format(table,_alias));
        _table = table;
        _tableAlias = _alias;

        return this;
    }

    QueryBuilder select(string[] column...)
    {
        _type = QUERY_TYPE.SELECT;
        _select = column;
        return this;
    }

    QueryBuilder update(string table = null, string _alias = null)
    {
        _type = QUERY_TYPE.UPDATE;
        if (table != null)
            _table = table;
        if (_alias != null)
            _tableAlias = _alias;
        return this;
    }

    QueryBuilder del(string table = null, string _alias = null)
    {
        _type = QUERY_TYPE.DELETE;
        if (table != null)
            _table = table;
        if (_alias != null)
            _tableAlias = _alias;
        return this;
    }

    QueryBuilder insert(string table)
    {
        _type = QUERY_TYPE.INSERT;
        _table = table;
        return this;
    }

    QueryBuilder showTables()
    {
        _type = QUERY_TYPE.SHOW_TABLES;
        return this;
    }

    QueryBuilder descTable(string tableName)
    {
        _type = QUERY_TYPE.DESC_TABLE;
        _table = tableName;
        return this;
    }

    QueryBuilder join(JoinMethod joinMethod, string table,
            string tablealias, string joinWhere)
    {
        _join ~= new JoinExpression(joinMethod, table, tablealias, joinWhere);
        return this;
    }

    QueryBuilder join(JoinMethod joinMethod, string table, string joinWhere)
    {
        return join(joinMethod, table, table, joinWhere);
    }

    QueryBuilder innerJoin(string table, string tablealias, string joinWhere)
    {
        return join(JoinMethod.InnerJoin, table, tablealias, joinWhere);
    }

    QueryBuilder innerJoin(string table, string joinWhere)
    {
        return innerJoin(table, table, joinWhere);
    }

    QueryBuilder leftJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.LeftJoin, table, tableAlias, joinWhere);
    }

    QueryBuilder leftJoin(string table, string joinWhere)
    {
        return leftJoin(table, table, joinWhere);
    }

    QueryBuilder rightJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.RightJoin, table, tableAlias, joinWhere);
    }

    QueryBuilder rightJoin(string table, string joinWhere)
    {
        return rightJoin(table, table, joinWhere);
    }

    QueryBuilder fullJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.FullJoin, table, tableAlias, joinWhere);
    }

    QueryBuilder fullJoin(string table, string joinWhere)
    {
        return fullJoin(table, table, joinWhere);
    }

    QueryBuilder crossJoin(string table, string tableAlias)
    {
        return join(JoinMethod.CrossJoin, table, tableAlias, null);
    }

    QueryBuilder crossJoin(string table)
    {
        return crossJoin(table, table);
    }

    QueryBuilder setAutoIncrease(string key)
    {
        _autoIncreaseKey = key;
        return this;
    }

    string getAutoIncrease()
    {
        return _autoIncreaseKey;
    }

    bool getDistinct()
    {
        return _distinct;
    }

    QueryBuilder setDistinct(bool b)
    {
        _distinct = b;
        return this;
    }

    QueryBuilder where(T)(Comparison!T comExpr)
    {
        _where = getExprStr!T(comExpr);
        return this;
    }

    QueryBuilder whereAnd(T)(Comparison!T comExpr)
    {
        _whereAnd ~= getExprStr!T(comExpr);
        return this;
    }

    QueryBuilder whereOr(T)(Comparison!T comExpr)
    {
        _whereOr ~= getExprStr!T(comExpr);
        return this;
    }

    private string getExprStr(T)(Comparison!T comExpr)
    {
        static if (is(T == string) || is(T == String) || is(T == Nullable!string)) {
            return comExpr.variant ~ " " ~ comExpr.operator ~ " " ~ 
                escapeWithQuotes(comExpr.value.to!string);
        } else {
            return comExpr.variant ~ " " ~ comExpr.operator ~ " " ~ comExpr.value.to!string;
        }
    }

    QueryBuilder where(string expression)
    {
        _where = expression;
        return this;
    }

    QueryBuilder whereAnd(string expression)
    {
        _whereAnd ~= expression;
        return this;
    }

    QueryBuilder whereOr(string expression)
    {
        _whereOr ~= expression;
        return this;
    }

    QueryBuilder groupBy(string expression)
    {
        _groupBy ~= expression;
        return this;
    }

    QueryBuilder orderBy(string column)
    {
        _orderBy ~= column;
        return this;
    }

    QueryBuilder orderBy(string[] columns...)
    {
        _orderBy = columns;
        return this;
    }

    QueryBuilder offset(int offset)
    {
        _offset = offset;
        return this;
    }

    QueryBuilder limit(int limit)
    {
        _limit = limit;
        return this;
    }

    QueryBuilder having(string expression)
    {
        _having = expression;
        return this;
    }

    QueryBuilder values(Variant[string] arr)
    {
        // logDebug("set values  : ",arr);
        foreach (key, value; arr)
        {
            auto expr = new ValueVariant(key, value);
            _values[key] = expr;
        }
        return this;
    }

    QueryBuilder set(R)(string fieldName, string columnName, string tableName, R param)
    {
        version(HUNT_DB_DEBUG) {
            tracef("---(fieldName: %s, columnName: %s, value: %s,  type: %s )", 
                fieldName, columnName, param, typeid(param));
        }

        if(fieldName in _values) {
            warningf("Key exists: %s", fieldName);
        }

        _values[fieldName] = new ValueVariant(columnName, param);

        // static if (is(R == int) || is(R == uint))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, param);
        // }
        // else static if (is(R == string) || is(R == char) || is(R == byte[]))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new String(param));
        // }
        // else static if (is(R == bool))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Boolean(param));
        // }
        // else static if (is(R == double))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Double(param));
        // }
        // else static if (is(R == float))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Float(param));
        // }
        // else static if (is(R == short) || is(R == ushort))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Short(param));
        // }
        // else static if (is(R == long) || is(R == ulong))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Long(param));
        // }
        // else static if (is(R == byte) || is(R == ubyte))
        // {
        //     _values[fieldName] = new ValueVariant(columnName, new Byte(param));
        // }
        // // else static if (is(R == Object))
        // // {
        // //     _values[fieldName] = new ValueVariant(columnName,new String(param.toString));
        // // }
        // else
        // {
        //     _values[fieldName] = new ValueVariant(columnName, param);
        // }

        return this;
    }


    QueryBuilder setParameter(R)(string key, R param)
    {
        // static if (is(R == int) || is(R == uint))
        // {
        //     _parameters[key] = new Integer(param);
        // }
        // else static if (is(R == string) || is(R == char) || is(R == byte[]))
        // {
        //     _parameters[key] = new String(param);
        // }
        // else static if (is(R == bool))
        // {
        //     _parameters[key] = new Boolean(param);
        // }
        // else static if (is(R == double))
        // {
        //     _parameters[key] = new Double(param);
        // }
        // else static if (is(R == float))
        // {
        //     _parameters[key] = new Float(param);
        // }
        // else static if (is(R == short) || is(R == ushort))
        // {
        //     _parameters[key] = new Short(param);
        // }
        // else static if (is(R == long) || is(R == ulong))
        // {
        //     _parameters[key] = new Long(param);
        // }
        // else static if (is(R == byte) || is(R == ubyte))
        // {
        //     _parameters[key] = new Byte(param);
        // }
        // else static if(is(R == class))
        // {
        //     _parameters[key] = param;
        // }
        // else
        // {
        //     throw new Exception("IllegalArgument not support : " ~ R.stringof);
        // }

        _parameters[key] = Variant(param);

        return this;
    }

    string parameterized(string sql, Variant[string] params)
    {
        foreach (string k, Variant v; params)
        {
            auto re = regex(r":" ~ k ~ r"([^\w]*)", "g");
            version(HUNT_DB_DEBUG) tracef("value: %s, type: %s", v.toString(), typeid(v));
            // if (cast(Nullable!string)v !is null)
            version(HUNT_DB_DEBUG) warning("type: ", v.type);
            if(v.type == typeid(string))
            {
                sql = sql.replaceAll(re,  escapeLiteral(v.toString()) ~ "$1");
            }
            else
            {
                sql = sql.replaceAll(re, v.toString() ~ "$1" );
            }
        }
        return sql;
    }

    override string toString()
    {
        if (!_table.length && _type != QUERY_TYPE.SHOW_TABLES)
            throw new Exception("query build table name not exists");
        string str;
        try
        {
            switch (_type)
            {
            case QUERY_TYPE.SELECT:
                {
                    auto builder = new SQLSelectBuilderImpl(_dbType.name);
                    builder.from(_table, _tableAlias);
                    // warning(_select);
                    builder.select(_select);
                    if (_join.length > 0)
                    {
                        foreach (item; _join)
                        {
                            if (item._join == JoinMethod.LeftJoin)
                                builder.leftJoin(item._table, item._tableAlias, item._on);
                            else if (item._join == JoinMethod.RightJoin)
                                builder.rightJoin(item._table, item._tableAlias, item._on);
                            else if (item._join == JoinMethod.InnerJoin)
                                builder.innerJoin(item._table, item._tableAlias, item._on);
                        }
                    }

                    {
                        if (_where.length > 0)
                            builder.where(_where);
                        if (_whereAnd.length > 0)
                        {
                            foreach (item; _whereAnd)
                                builder.whereAnd(item);
                        }
                        if (_whereOr.length > 0)
                        {
                            foreach (item; _whereOr)
                                builder.whereOr(item);
                        }
                    }

                    if (_groupBy.length > 0)
                    {
                        foreach (item; _groupBy)
                        {
                            builder.groupBy(item);
                        }
                    }
                    if (_orderBy.length > 0)
                    {
                        foreach (item; _orderBy)
                        {
                            builder.orderBy(item);
                        }
                    }
                    if (_having.length > 0)
                        builder.having(_having);
                    if (_limit != int.init)
                        builder.limit(_limit);
                    if (_offset != int.init)
                        builder.offset(_offset);
                    if (_distinct)
                        builder.setDistinct();
                    str = builder.toString();
                    str = parameterized(str, _parameters);
                }
                break;

            case QUERY_TYPE.UPDATE:
                {
                    SQLUpdateBuilderImpl builder = new SQLUpdateBuilderImpl(_dbType.name);
                    builder.from(_table, _tableAlias);
                    // logDebug("set values len : ",_values.length);
                    if (_values.length > 0)
                    {
                        if(_dbType == DBType.MYSQL) {
                            foreach (ValueVariant item; _values) {
                                version(HUNT_DB_DEBUG) tracef("Update: %s", item);
                                builder.setValue("`" ~ item.key ~ "`", item.value);
                            }
                        } else {
                            foreach (ValueVariant item; _values) {
                                version(HUNT_DB_DEBUG) tracef("Update: %s", item);
                                builder.setValue("\"" ~ item.key ~ "\"", item.value);
                            }
                        }
                    }

                    {
                        if (_where.length > 0)
                            builder.where(_where);
                        if (_whereAnd.length > 0)
                        {
                            foreach (item; _whereAnd)
                                builder.whereAnd(item);
                        }
                        if (_whereOr.length > 0)
                        {
                            foreach (item; _whereOr)
                                builder.whereOr(item);
                        }
                    }

                    if (_groupBy.length > 0)
                    {
                        foreach (item; _groupBy)
                        {
                            builder.groupBy(item);
                        }
                    }
                    if (_orderBy.length > 0)
                    {
                        foreach (item; _orderBy)
                        {
                            builder.orderBy(item);
                        }
                    }
                    if (_having.length > 0)
                        builder.having(_having);
                    if (_limit != int.init)
                        builder.limit(_limit);
                    if (_offset != int.init)
                        builder.offset(_offset);

                    str = builder.toString();
                    str = parameterized(str, _parameters);
                }
                break;
            case QUERY_TYPE.DELETE:
                {
                    auto builder = new SQLDeleteBuilderImpl(_dbType.name);
                    builder.from(_table, _tableAlias);

                    {
                        if (_where.length > 0)
                            builder.where(_where);
                        if (_whereAnd.length > 0)
                        {
                            foreach (item; _whereAnd)
                                builder.whereAnd(item);
                        }
                        if (_whereOr.length > 0)
                        {
                            foreach (item; _whereOr)
                                builder.whereOr(item);
                        }
                    }

                    if (_groupBy.length > 0)
                    {
                        foreach (item; _groupBy)
                        {
                            builder.groupBy(item);
                        }
                    }
                    if (_orderBy.length > 0)
                    {
                        foreach (item; _orderBy)
                        {
                            builder.orderBy(item);
                        }
                    }
                    if (_having.length > 0)
                        builder.having(_having);
                    if (_limit != int.init)
                        builder.limit(_limit);
                    if (_offset != int.init)
                        builder.offset(_offset);

                    str = builder.toString();
                    str = parameterized(str, _parameters);

                }
                break;
            case QUERY_TYPE.INSERT:
                {
                    str ~= " insert into " ~ _table;
                    string keys;
                    string values;
                    string tempValue;
                    bool isFirstItem = true;
                    foreach (k, v; _values)
                    {
                        TypeInfo fieldTypeInfo = v.value.type;
                        version(HUNT_DB_DEBUG) {
                            tracef("field: %s, type: %s, value: %s", k, fieldTypeInfo, v.value);
                        }

                        if(fieldTypeInfo == typeid(string))
                        {
                            // logDebug("---Insert(%s , %s )".format(k,v.value));
                            tempValue = escapeWithQuotes(v.value.get!string());
                        } else if(fieldTypeInfo == typeid(byte[])) {
                            if(_dbType == DBType.POSTGRESQL) {
                                tempValue = format("'\\x%(%02X%)'", v.value.get!(byte[]));
                            } else if(_dbType == DBType.MYSQL) {
                                tempValue = format("unhex('%(%02X%)')", v.value.get!(byte[]));
                            } else {
                                throw new Exception("Unsupported type: " ~ fieldTypeInfo.toString());
                            }
                        } else if(fieldTypeInfo == typeid(ubyte[])) {
                            if(_dbType == DBType.POSTGRESQL) {
                                tempValue = format("'\\x%(%02X%)'", v.value.get!(ubyte[]));
                            } else if(_dbType == DBType.POSTGRESQL) {
                                tempValue = format("unhex('%(%02X%)')", v.value.get!(byte[]));
                            } else {
                                throw new Exception("Unsupported type: " ~ fieldTypeInfo.toString());
                            }
                        } else {
                            tempValue = v.value.toString();
                        }

                        if(isFirstItem) {
                            isFirstItem = false;
                            keys = k;
                            values = tempValue;
                        } else {
                            keys ~= ", " ~ k;
                            values ~= ", " ~ tempValue;
                        }

                    }
                    str ~= "(" ~ keys ~ ") VALUES(" ~ values ~ ")";
                }
                break;
            case QUERY_TYPE.COUNT:
                // str ~= " select count(*) " ~ _table;
                break;
            case QUERY_TYPE.SHOW_TABLES:
                if (_dbType == DBType.POSTGRESQL)
                    str ~= "select tablename from pg_tables where schemaname = 'public'";
                else
                    str ~= " show tables ";
                break;
            case QUERY_TYPE.DESC_TABLE:
                if (_dbType == DBType.POSTGRESQL) {
                    str ~= "SELECT column_name as Field, data_type FROM information_schema.columns" ~
                            " WHERE table_schema='public' and table_name='" ~ _table ~ "'";
                } else if (_dbType == DBType.MYSQL) {
                    str ~= "desc " ~ _table;
                // } else if (_dbType == DBType.SQLITE) {
                //     str ~= "select * from sqlite_master where type=\"table\" and name=\""
                //         ~ _table ~ "\"";
                }
                break;
            default:
                throw new Exception("query build method not found");
            }
            version(HUNT_DB_DEBUG) infof("Query string: %s", str);
        }
        catch (Exception ex)
        {
            version(HUNT_DEBUG) warning("Query Builder Exception : ", ex.msg);
            version(HUNT_DB_DEBUG) warning(ex);
            sqlDebugInfo();
        }

        return str;
    }

    private void sqlDebugInfo()
    {
        logDebug("{Type : %s  \n
                   table : ( %s , %s ) \n
                   select item :  %s  \n
                   where : %s  \n
                   whereAnd : %s \n
                   whereOr : %s \n
                   order by : %s \n
                   having : %s \n
                   group by : %s \n
                   limit : %s  \n
                   offset : %s \n
                   }".format(_type, _table, _tableAlias, _select, _where,
                _whereAnd, _whereOr, _orderBy, _having, _groupBy, _limit, _offset));
    }

    string escapeLiteral(string str) {
		
		if(_dbType == DBType.POSTGRESQL) {
			scope StringBuilder sb = new StringBuilder((cast(int)str.length + 10) / 10 * 11); // Add 10% for escaping.
			PgUtil.escapeLiteral(sb, str, true);

			return sb.toString();
		} else if(_dbType == DBType.MYSQL) {
            return MySQLUtil.escapeLiteral(str);
        }

		return str;
	}

    string escapeWithQuotes(string str) {

		if(_dbType == DBType.POSTGRESQL) {
			return PgUtil.escapeWithQuotes(str);
		} else if(_dbType == DBType.MYSQL) {
            return MySQLUtil.escapeWithQuotes(str);
        }

		return str;
	}
}
