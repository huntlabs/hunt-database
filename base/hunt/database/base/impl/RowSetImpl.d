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
module hunt.database.base.impl.RowSetImpl;

import hunt.database.base.impl.RowInternal;
import hunt.database.base.impl.SqlResultBase;

import hunt.database.base.RowIterator;
import hunt.database.base.RowSet;
import hunt.database.base.Row;

import hunt.Exceptions;
import hunt.Functions;

import std.array;
import std.variant;

/**
 * 
 */
class RowSetImpl : SqlResultBase!(RowSet, RowSetImpl), RowSet {

    static void accumulator(RowSetImpl set, Row row) {
        if (set.head is null) {
            set.head = set.tail = cast(RowInternal) row;
        } else {
            set.tail.setNext(cast(RowInternal) row);
            set.tail = set.tail.getNext();
        }
    }    

    static Function!(RowSet, RowSetImpl) FACTORY() {
        return (rs) { return cast(RowSetImpl) rs; } ;
    }

    private RowInternal head;
    private RowInternal tail;

    override
    RowSet value() {
        return this;
    }

    override
    string[] columnsNames() {
        return _columnNames;
    }

    override
    int rowCount() {
        return _updated;
    }

    override
    int size() {
        return _size;
    }

    Variant property(string key) {
        if(key.empty) {
            throw new IllegalArgumentException("Property can not be null");
        }

        if(properties is null)
            return Variant(null);
        
        return properties.get(key, Variant(null));
    }

    override
    RowSetImpl next() {
        return _next;
    }

    alias next = SqlResultBase!(RowSet, RowSetImpl).next;

    void append(Row row) {
        if (this.head is null) {
            this.head = this.tail = cast(RowInternal) row;
        } else {
            this.tail.setNext(cast(RowInternal) row);
            this.tail = this.tail.getNext();
        }        
    }

    // override int size() {
    //     return super.size();
    // }
    
    // override int rowCount() {
    //     return super.rowCount();
    // }

    // override string[] columnsNames() {
    //     return super.columnsNames();
    // }

    int opApply(scope int delegate(ref Row) dg) {

        int result = 0;
        RowInternal cur = head;
        while(cur !is null) {
            Row r = cur;
            result = dg(r);
            cur = cur.getNext();
        }
        return result;        
    }

    override
    RowIterator iterator() {
        return new IteratorImpl();
    }

    private class IteratorImpl : RowIterator {
        RowInternal current;

        this() {
            current = head;
        }

        bool empty() {
            return current is null;
        }

        Row front() {
            if (current is null) {
                throw new NoSuchElementException("No such element!");
            }

            return current;
        }

        void popFront() {
            if (current is null) {
                throw new NoSuchElementException();
            }
            current = current.getNext();
        }

        Row moveFront() {
            throw new NotImplementedException();
        }

        int opApply(scope int delegate(Row) dg) {
            int result = 0;
            RowInternal cur = head;
            while(cur !is null) {
                result = dg(cur);
                cur = cur.getNext();
            }
            return result;
        }

        /// Ditto
        int opApply(scope int delegate(size_t, Row) dg) {
            int result = 0;
            size_t index = 0;
            RowInternal cur = head;
            while(cur !is null) {
                result = dg(index++, cur);
                cur = cur.getNext();
            }
            return result;   
        }

    }
}
