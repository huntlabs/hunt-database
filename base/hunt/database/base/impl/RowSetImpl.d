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

class RowSetImpl : SqlResultBase!(RowSet, RowSetImpl), RowSet {

    // static Collector!(Row, RowSetImpl, RowSet) COLLECTOR = Collector.of(
    //     RowSetImpl::new,
    //     (set, row) -> {
    //         if (set.head is null) {
    //             set.head = set.tail = (RowInternal) row;
    //         } else {
    //             set.tail.setNext((RowInternal) row);;
    //             set.tail = set.tail.getNext();
    //         }
    //     },
    //     (set1, set2) -> null, // Shall not be invoked as this is sequential
    //     (set) -> set
    // );

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

    override
    RowSetImpl next() {
        return _next;
    }

    alias next = SqlResultBase!(RowSet, RowSetImpl).next;

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

        implementationMissing(false);
        return 0;
    }

    override
    RowIterator iterator() {
        implementationMissing(false);
        return null;
        // return new RowIterator() {
        //     RowInternal current = head;
        //     override
        //     boolean hasNext() {
        //         return current !is null;
        //     }
        //     override
        //     Row next() {
        //         if (current is null) {
        //             throw new NoSuchElementException();
        //         }
        //         RowInternal r = current;
        //         current = current.getNext();
        //         return r;
        //     }
        // };
    }
}
