module hunt.database.base.impl.NamedQueryImpl;

import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.RowDesc;

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PreparedStatement;

import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;

import hunt.logging.ConsoleLogger;

import std.variant;

/**
 * 
 */
abstract class NamedQueryImpl : PreparedQueryImpl, NamedQuery {

    private AbstractNamedQueryDesc _queryDesc;
    protected Variant[string] _parameters;

    this(DbConnection conn, PreparedStatement ps, AbstractNamedQueryDesc queryDesc) {
        super(conn, ps);
        _queryDesc = queryDesc;
    }

    

    // void setParameter(string name, Variant value) {
    //     version(HUNT_DEBUG) {
    //         auto itemPtr = name in _parameters;
    //         if(itemPtr !is null) {
    //             warning("% will be overwrited with %s", name, value.toString());
    //         }
    //     }


    //     // TODO: Tasks pending completion -@zhangxueping at 2019-10-01T13:35:23+08:00
    //     // validate the type of parameter
    //     // hunt.database.driver.mysql.impl.codec.ColumnDefinition;

    //     // RowDesc rowDesc = getPreparedStatement().rowDesc();
    //     // warning(rowDesc.toString());

    //     _parameters[name] = value;
    // }

    override PreparedQuery execute(RowSetHandler handler) {
        ArrayTuple tuples = new ArrayTuple(_queryDesc.getSize());
        foreach(string name, ref Variant value; _parameters) {
            int[] indexSet = _queryDesc.getIndexSet()[name];
            foreach(int index; indexSet) {
                tuples.add(index, value);
            }
        }
        return execute(tuples, handler);
    }

    alias execute = typeof(super).execute;
}