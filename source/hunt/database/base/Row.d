/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
module hunt.database.base.Row;

import hunt.database.base.Annotations;
import hunt.database.base.Tuple;

import hunt.logging;


import std.array;
import std.format;
import std.functional;
import std.meta;
import std.traits;
import std.typecons : Nullable;
import std.variant;

/**
 * 
 */
interface Row : Tuple {

    /**
     * Get a column name at {@code pos}.
     *
     * @param pos the column position
     * @return the column name or {@code null}
     */
    string getColumnName(int pos);

    /**
     * Get a column position for the given column {@code name}.
     *
     * @param name the column name
     * @return the column name or {@code -1} if not found
     */
    int getColumnIndex(string name);
    
    /**
     * Get an object value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    Variant getValue(string name);
    alias getValue = Tuple.getValue;
    alias opIndex = getValue;

    // Variant opIndex(string name);
    // alias opIndex = Tuple.opIndex;

    /**
     * Get a boolean value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    bool getBoolean(string name);
    alias getBoolean = Tuple.getBoolean;


    /**
     * Get a short value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    short getShort(string name);
    alias getShort = Tuple.getShort;

    /**
     * Get an integer value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    int getInteger(string name);
    alias getInteger = Tuple.getInteger;

    /**
     * Get a long value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    long getLong(string name);
    alias getLong = Tuple.getLong;

    /**
     * Get a float value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    float getFloat(string name);
    alias getFloat = Tuple.getFloat;

    /**
     * Get a double value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    double getDouble(string name);
    alias getDouble = Tuple.getDouble;

    /**
     * Get a string value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    string getString(string name);
    alias getString = Tuple.getString;

    /**
     * Get a buffer value at {@code pos}.
     *
     * @param name the column
     * @return the value or {@code null}
     */
    // Buffer getBuffer(string name);
    byte[] getBuffer(string name);
    alias getBuffer = Tuple.getBuffer;

    // /**
    //  * Get a temporal value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Temporal getTemporal(string name);

    // /**
    //  * Get {@link java.time.LocalDate} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDate getLocalDate(string name);

    // /**
    //  * Get {@link java.time.LocalTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalTime getLocalTime(string name);

    // /**
    //  * Get {@link java.time.LocalDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDateTime getLocalDateTime(string name);

    // /**
    //  * Get {@link java.time.OffsetTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetTime getOffsetTime(string name);

    // /**
    //  * Get {@link java.time.OffsetDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetDateTime getOffsetDateTime(string name);

    // /**
    //  * Get {@link java.util.UUID} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // UUID getUUID(string name);

    // /**
    //  * Get {@link BigDecimal} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // BigDecimal getBigDecimal(string name);

    // /**
    //  * Get an array of {@link Integer} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Integer[] getIntegerArray(string name);

    // /**
    //  * Get an array of {@link Boolean} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Boolean[] getBooleanArray(string name);

    // /**
    //  * Get an array of {@link Short} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Short[] getShortArray(string name);

    // /**
    //  * Get an array of {@link Long} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Long[] getLongArray(string name);

    // /**
    //  * Get an array of {@link Float} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Float[] getFloatArray(string name);

    // /**
    //  * Get an array of {@link Double} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Double[] getDoubleArray(string name);

    // /**
    //  * Get an array of {@link string} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // string[] getStringArray(string name);

    // /**
    //  * Get an array of {@link LocalDate} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDate[] getLocalDateArray(string name);

    // /**
    //  * Get an array of {@link LocalTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalTime[] getLocalTimeArray(string name);

    // /**
    //  * Get an array of {@link OffsetTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetTime[] getOffsetTimeArray(string name);

    // /**
    //  * Get an array of {@link LocalDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // LocalDateTime[] getLocalDateTimeArray(string name);

    // /**
    //  * Get an array of {@link OffsetDateTime} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // OffsetDateTime[] getOffsetDateTimeArray(string name);

    // /**
    //  * Get an array of {@link Buffer} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // Buffer[] getBufferArray(string name);

    // /**
    //  * Get an array of {@link UUID} value at {@code pos}.
    //  *
    //  * @param name the column
    //  * @return the value or {@code null}
    //  */
    // UUID[] getUUIDArray(string name);

    // <T> T[] getValues(Class!(T) type, int idx);

    alias getAs = bind;

    final T bind(T, alias getColumnNameFun="b")() if(is(T == struct)) {
        T r;

        static if(hasUDA!(T, Table)) {
            enum tableName = getUDAs!(T, Table)[0].name;
        } else {
            enum tableName = T.stringof;
        }

        bindObject!(tableName, getColumnNameFun)(r);

        return r;
    }

    final void bindObject(string tableName = T.stringof, 
            alias getColumnNameFun="b", T)(ref T obj) if(is(T == struct)) {
        alias getColumnName = binaryFun!getColumnNameFun;

        // current fields in T
		static foreach (string member; FieldNameTuple!T) {{
            alias currentMember = Alias!(__traits(getMember, T, member));
            alias memberType = typeof(__traits(getMember, T, member));

            static if(hasUDA!(currentMember, Ignore)) {
                version(HUNT_DEBUG) { warningf("Field %s.%s ignored.", T.stringof, member); }
            } else static if(is(memberType == class)) { 
                __traits(getMember, obj, member) = bind!(memberType, getColumnNameFun)();
            } else static if(is(memberType == struct) && !is(memberType : Nullable!U, U)) {
                __traits(getMember, obj, member) = bind!(memberType, getColumnNameFun)();
            } else {
                static if(hasUDA!(currentMember, Column)) {
                    enum memberColumnAttr = getUDAs!(currentMember, Column)[0];
                    enum string memberColumnName = memberColumnAttr.name;
                    static assert(!memberColumnName.empty());

                    enum int memeberColumnOrder = memberColumnAttr.order;
                } else {
                    enum string memberColumnName = member;
                    enum int memeberColumnOrder = -1;
                }

                enum string columnName = getColumnName(tableName, memberColumnName);
                __traits(getMember, obj, member) = getValueAs!(columnName, memeberColumnOrder, memberType)();
            }
        }}
    }

    final T bind(T, bool traverseBase=true, alias getColumnNameFun="b")() 
            if(is(T == class) && __traits(compiles, new T())) {
        T r = new T();

        static if(hasUDA!(T, Table)) {
            enum tableName = getUDAs!(T, Table)[0].name;
        } else {
            enum tableName = T.stringof;
        }

        bindObject!(tableName, traverseBase, getColumnNameFun, T)(r); // bug
        return r;
    }

    final void bindObject(string tableName = T.stringof,  bool traverseBase=true,
            alias getColumnNameFun="b", T)(T obj) if(is(T == class)) {
        alias getColumnName = binaryFun!getColumnNameFun;

        // current fields in T
		static foreach (string member; FieldNameTuple!T) {{
            alias currentMember = Alias!(__traits(getMember, T, member));
            alias memberType = typeof(__traits(getMember, T, member));

            static if(hasUDA!(currentMember, Ignore)) {
                version(HUNT_DEBUG) { warningf("Field %s.%s ignored.", T.stringof, member); }
            } else static if((is(memberType == struct) && !is(memberType : Nullable!U, U))) {
                __traits(getMember, obj, member) = bind!(memberType, getColumnNameFun)();
            } else static if(is(memberType == class)) {
                __traits(getMember, obj, member) = bind!(memberType, traverseBase,  getColumnNameFun)(); // bug
            } else {
                static if(hasUDA!(currentMember, Column)) {
                    enum memberColumnAttr = getUDAs!(currentMember, Column)[0];
                    enum string memberColumnName = memberColumnAttr.name;
                    static assert(!memberColumnName.empty());

                    enum int memeberColumnOrder = memberColumnAttr.order;
                } else {
                    enum string memberColumnName = member;
                    enum int memeberColumnOrder = -1;
                }

                enum string columnName = getColumnName(tableName, memberColumnName);
                __traits(getMember, obj, member) = getValueAs!(columnName, memeberColumnOrder, memberType)();
            }
        }}

        static if(traverseBase) {
            // all fields in the super of T
            alias baseClasses = BaseClassesTuple!T;
            static if(baseClasses.length >= 2) { // skip Object
                bindObject!(tableName, traverseBase, getColumnNameFun, baseClasses[0])(obj);
            }
        }
    }

    final private T getValueAs(string memberColumnName, int memeberColumnOrder = -1, T)() {
        int columnIndex = memeberColumnOrder;
        static if(memeberColumnOrder == -1) {
            columnIndex = getColumnIndex(memberColumnName);
            if(columnIndex == -1) {
                version(HUNT_DEBUG) warningf("Column does not exist: %s", memberColumnName);
                return T.init;
            }
        }

        if(columnIndex>=this.size()) {
            version(HUNT_DEBUG) warningf("Index is out of range: %d>%d", columnIndex, this.size());
            return T.init;
        }

        Variant currentColumnValue = getValue(columnIndex);
        version(HUNT_DB_DEBUG) {
            tracef("column, name=%s, index=%d, type {target: %s, source: %s}", 
                memberColumnName, columnIndex, T.stringof, currentColumnValue.type);
        }

        static if(is(T : Nullable!U, U)) {
            auto memberTypeInfo = typeid(U);
            if(memberTypeInfo == currentColumnValue.type || currentColumnValue.convertsTo!(U)) {
                // 1) If the types are same, or the column's type can convert to the member's type
                U tmp = currentColumnValue.get!U();
                return T(tmp);
            } else if(currentColumnValue == null) {
                return T.init;
            } else {
                // 2) try to coerce to T
                U tmp = currentColumnValue.coerce!U();
                return T(tmp);
            }
        } else {
            auto memberTypeInfo = typeid(T);
            if(memberTypeInfo == currentColumnValue.type || currentColumnValue.convertsTo!(T)) {
                // 1) If the types are same, or the column's type can convert to the member's type
                return currentColumnValue.get!T();
            } else if(currentColumnValue == null) {
                return T.init;
            } else {
                // 2) try to coerce to T
                return currentColumnValue.coerce!T();
                // assert(false, format("Can't convert a value from %s to %s", 
                //     currentColumnValue.type, memberTypeInfo));
            }
        }

    }
}
