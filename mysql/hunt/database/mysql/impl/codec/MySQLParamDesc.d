module hunt.database.mysql.impl.codec.MySQLParamDesc;

import hunt.database.mysql.impl.codec.ColumnDefinition;
import hunt.database.mysql.impl.codec.DataFormat;

import hunt.database.base.impl.ParamDesc;
import hunt.database.base.Util;

import hunt.collection.List;

import std.variant;

/**
 * 
 */
class MySQLParamDesc : ParamDesc {
    private ColumnDefinition[] _paramDefinitions;

    this(ColumnDefinition[] paramDefinitions) {
        this._paramDefinitions = paramDefinitions;
    }

    ColumnDefinition[] paramDefinitions() {
        return _paramDefinitions;
    }

    override
    string prepare(List!(Variant) values) {
        if (values.size() != _paramDefinitions.length) {
            return buildReport(values);
        }
//    for (int i = 0;i < paramDefinitions.length;i++) {
//      DataType paramDataType = paramDefinitions[i].type();
//      Object value = values.get(i);
//      Object val = DataTypeCodec.prepare(paramDataType, value);
//      if (val != value) {
//        if (val == DataTypeCodec.REFUSED_SENTINEL) {
//          return buildReport(values);
//        } else {
//          values.set(i, val);
//        }
//      }
//    }
        // TODO we can't really achieve type check for params because MySQL prepare response does not provide any useful information for param definitions
        return null;
    }

    // reuse from pg
    private string buildReport(List!(Variant) values) {
        string[] types;
        paramDataTypes.each!((type) { types = types ~ type.decodingType; });

        return Util.buildInvalidArgsError(values.toArray(), types);
    }
}
