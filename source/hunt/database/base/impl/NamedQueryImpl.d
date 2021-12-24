module hunt.database.base.impl.NamedQueryImpl;

import hunt.database.base.impl.NamedQueryDesc;
import hunt.database.base.impl.PreparedQueryImpl;
import hunt.database.base.impl.RowDesc;

import hunt.database.base.impl.ArrayTuple;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.PreparedStatement;

import hunt.database.base.PreparedQuery;
import hunt.database.base.RowSet;

import hunt.logging;

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