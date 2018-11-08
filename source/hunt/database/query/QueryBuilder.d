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

import hunt.database;

import hunt.sql;
import hunt.lang;
import hunt.logging;
import std.array;
import std.string;
import std.conv;

class QueryBuilder
{

    private string _dbType = DBType.MYSQL.name;

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
    private Object[string] _parameters;
    private Expr _expr;
    private bool _distinct;
    private string _autoIncreaseKey;
    private Database _db;

    public this(Database db)
    {
        _db = db;
        if (_db.getOption().isPgsql())
            _dbType = DBType.POSTGRESQL.name;
        else if (_db.getOption().isSqlite())
            _dbType = DBType.SQLITE.name;
        else
            _dbType = DBType.MYSQL.name;
    }

    @property public Expr expr()
    {
        if (_expr is null)
            _expr = new Expr();
        return _expr;
    }

    public QueryBuilder from(string table, string _alias = null)
    {
        // logDebug("QueryBuilder From : %s , %s ".format(table,_alias));
        _table = table;
        _tableAlias = _alias;

        return this;
    }

    public QueryBuilder select(string[] column...)
    {
        _type = QUERY_TYPE.SELECT;
        _select = column;
        return this;
    }

    public QueryBuilder update(string table = null, string _alias = null)
    {
        _type = QUERY_TYPE.UPDATE;
        if (table != null)
            _table = table;
        if (_alias != null)
            _tableAlias = _alias;
        return this;
    }

    public QueryBuilder del(string table = null, string _alias = null)
    {
        _type = QUERY_TYPE.DELETE;
        if (table != null)
            _table = table;
        if (_alias != null)
            _tableAlias = _alias;
        return this;
    }

    public QueryBuilder insert(string table)
    {
        _type = QUERY_TYPE.INSERT;
        _table = table;
        return this;
    }

    public QueryBuilder showTables()
    {
        _type = QUERY_TYPE.SHOW_TABLES;
        return this;
    }

    public QueryBuilder descTable(string tableName)
    {
        _type = QUERY_TYPE.DESC_TABLE;
        _table = tableName;
        return this;
    }

    public QueryBuilder join(JoinMethod joinMethod, string table,
            string tablealias, string joinWhere)
    {
        _join ~= new JoinExpression(joinMethod, table, tablealias, joinWhere);
        return this;
    }

    public QueryBuilder join(JoinMethod joinMethod, string table, string joinWhere)
    {
        return join(joinMethod, table, table, joinWhere);
    }

    public QueryBuilder innerJoin(string table, string tablealias, string joinWhere)
    {
        return join(JoinMethod.InnerJoin, table, tablealias, joinWhere);
    }

    public QueryBuilder innerJoin(string table, string joinWhere)
    {
        return innerJoin(table, table, joinWhere);
    }

    public QueryBuilder leftJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.LeftJoin, table, tableAlias, joinWhere);
    }

    public QueryBuilder leftJoin(string table, string joinWhere)
    {
        return leftJoin(table, table, joinWhere);
    }

    public QueryBuilder rightJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.RightJoin, table, tableAlias, joinWhere);
    }

    public QueryBuilder rightJoin(string table, string joinWhere)
    {
        return rightJoin(table, table, joinWhere);
    }

    public QueryBuilder fullJoin(string table, string tableAlias, string joinWhere)
    {
        return join(JoinMethod.FullJoin, table, tableAlias, joinWhere);
    }

    public QueryBuilder fullJoin(string table, string joinWhere)
    {
        return fullJoin(table, table, joinWhere);
    }

    public QueryBuilder crossJoin(string table, string tableAlias)
    {
        return join(JoinMethod.CrossJoin, table, tableAlias, null);
    }

    public QueryBuilder crossJoin(string table)
    {
        return crossJoin(table, table);
    }

    public QueryBuilder setAutoIncrease(string key)
    {
        _autoIncreaseKey = key;
        return this;
    }

    public string getAutoIncrease()
    {
        return _autoIncreaseKey;
    }

    public bool getDistinct()
    {
        return _distinct;
    }

    public QueryBuilder setDistinct(bool b)
    {
        _distinct = b;
        return this;
    }

    public QueryBuilder where(T)(Comparison!T comExpr)
    {
        _where = getExprStr!T(comExpr);
        return this;
    }

    public QueryBuilder whereAnd(T)(Comparison!T comExpr)
    {
        _whereAnd ~= getExprStr!T(comExpr);
        return this;
    }

    public QueryBuilder whereOr(T)(Comparison!T comExpr)
    {
        _whereOr ~= getExprStr!T(comExpr);
        return this;
    }

    private string getExprStr(T)(Comparison!T comExpr)
    {
        static if (is(T == string) || is(T == String))
            return comExpr.variant ~ " " ~ comExpr.operator ~ " " ~ quoteSqlString(
                    comExpr.value.to!string);
        else
            return comExpr.variant ~ " " ~ comExpr.operator ~ " " ~ comExpr.value.to!string;
    }

    public QueryBuilder where(string expression)
    {
        // logDebug("where(string) : ",expression);
        _where = expression;
        return this;
    }

    public QueryBuilder whereAnd(string expression)
    {
        _whereAnd ~= expression;
        return this;
    }

    public QueryBuilder whereOr(string expression)
    {
        _whereOr ~= expression;
        return this;
    }

    public QueryBuilder groupBy(string expression)
    {
        _groupBy ~= expression;
        return this;
    }

    public QueryBuilder orderBy(string column)
    {
        _orderBy ~= column;
        return this;
    }

    public QueryBuilder orderBy(string[] columns...)
    {
        _orderBy = columns;
        return this;
    }

    public QueryBuilder offset(int offset)
    {
        _offset = offset;
        return this;
    }

    public QueryBuilder limit(int limit)
    {
        _limit = limit;
        return this;
    }

    public QueryBuilder having(string expression)
    {
        _having = expression;
        return this;
    }

    public QueryBuilder values(Object[string] arr)
    {
        // logDebug("set values  : ",arr);
        foreach (key, value; arr)
        {
            auto expr = new ValueVariant(key, value);
            _values[key] = expr;
        }
        return this;
    }

    public QueryBuilder set(R)(string key, R param)
    {
        // logDebug("---sey param : ( %s , %s )".format(R.stringof,param));

        static if (is(R == int) || is(R == uint))
        {
            _values[key] = new ValueVariant(key, new Integer(param));
        }
        else static if (is(R == string) || is(R == char) || is(R == byte[]))
        {
            _values[key] = new ValueVariant(key, new String(param));
        }
        else static if (is(R == bool))
        {
            _values[key] = new ValueVariant(key, new Boolean(param));
        }
        else static if (is(R == double))
        {
            _values[key] = new ValueVariant(key, new Double(param));
        }
        else static if (is(R == float))
        {
            _values[key] = new ValueVariant(key, new Float(param));
        }
        else static if (is(R == short) || is(R == ushort))
        {
            _values[key] = new ValueVariant(key, new Short(param));
        }
        else static if (is(R == long) || is(R == ulong))
        {
            _values[key] = new ValueVariant(key, new Long(param));
        }
        else static if (is(R == byte) || is(R == ubyte))
        {
            _values[key] = new ValueVariant(key, new Byte(param));
        }
        // else static if (is(R == Object))
        // {
        //     _values[key] = new ValueVariant(key,new String(param.toString));
        // }
        else
        {
            _values[key] = new ValueVariant(key, param);
        }

        return this;
    }

    public QueryBuilder setParameter(R)(string key, R param)
    {
        static if (is(R == int) || is(R == uint))
        {
            _parameters[key] = new Integer(param);
        }
        else static if (is(R == string) || is(R == char) || is(R == byte[]))
        {
            _parameters[key] = new String(param);
        }
        else static if (is(R == bool))
        {
            _parameters[key] = new Boolean(param);
        }
        else static if (is(R == double))
        {
            _parameters[key] = new Double(param);
        }
        else static if (is(R == float))
        {
            _parameters[key] = new Float(param);
        }
        else static if (is(R == short) || is(R == ushort))
        {
            _parameters[key] = new Short(param);
        }
        else static if (is(R == long) || is(R == ulong))
        {
            _parameters[key] = new Long(param);
        }
        else static if (is(R == byte) || is(R == ubyte))
        {
            _parameters[key] = new Byte(param);
        }
        else static if(is(R == class))
        {
            _parameters[key] = param;
        }
        else
        {
            throw new Exception("IllegalArgument not support : " ~ R.stringof);
        }


        return this;
    }

    public string parameterized(string sql, Object[string] params)
    {
        foreach (k, v; params)
        {
            auto re = regex(r":" ~ k ~ r"([^\w])", "g");
            if (cast(String) v !is null)
            {
                sql = sql.replaceAll(re, _db.escapeLiteral(v.toString()) ~ "$1");
            }
            else
            {
                sql = sql.replaceAll(re, v.toString() ~ "$1" );
            }
        }
        return sql;
    }

    override public string toString()
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
                    auto builder = new SQLSelectBuilderImpl(_dbType);
                    builder.from(_table, _tableAlias);
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
                    auto builder = new SQLUpdateBuilderImpl(_dbType);
                    builder.from(_table, _tableAlias);
                    // logDebug("set values len : ",_values.length);
                    if (_values.length > 0)
                    {
                        foreach (item; _values)
                        {
                    logDebug("set values  : ",item);

                            builder.setValue(item.key, item.value);
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
                    auto builder = new SQLDeleteBuilderImpl(_dbType);
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
                    foreach (k, v; _values)
                    {
                        keys ~= k ~ ",";
                        if (cast(String)(v.value) !is null)
                        {
                            // logDebug("---Insert(%s , %s )".format(k,v.value));
                            values ~= _db.escapeLiteral(v.value.toString()) ~ ",";
                        }
                        else
                            values ~= v.value.toString() ~ ",";
                    }
                    str ~= "(" ~ keys[0 .. $ - 1] ~ ") VALUES(" ~ values[0 .. $ - 1] ~ ")";
                }
                break;
            case QUERY_TYPE.COUNT:
                // str ~= " select count(*) " ~ _table;
                break;
            case QUERY_TYPE.SHOW_TABLES:
                if (_dbType == DBType.POSTGRESQL.name)
                    str ~= "select tablename from pg_tables where schemaname = 'public'";
                else
                    str ~= " show tables ";
                break;
            case QUERY_TYPE.DESC_TABLE:
                if (_dbType == DBType.POSTGRESQL.name)
                    str ~= "SELECT column_name as Field, data_type FROM information_schema.columns WHERE table_schema='public' and table_name='" ~ _table ~ "'";
                else if (_dbType == DBType.MYSQL.name)
                    str ~= "desc " ~ _table;
                else if (_dbType == DBType.SQLITE.name)
                    str ~= "select * from sqlite_master where type=\"table\" and name=\""
                        ~ _table ~ "\"";
                break;
            default:
                throw new Exception("query build method not found");
            }
            // logDebug("QueryBuilder : ", str);
        }
        catch (Exception e)
        {
            logDebug("Query Builder Exception : ", e.msg);
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
}
