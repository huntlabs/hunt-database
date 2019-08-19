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

module hunt.database.postgresql.impl.codec.RowResultDecoder;

import hunt.database.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.Row;
import hunt.database.postgresql.impl.RowImpl;
import hunt.database.base.impl.RowDecoder;

// import java.util.function.BiConsumer;
// import java.util.stream.Collector;

import hunt.collection.ByteBuffer;
import hunt.Functions;

abstract class AbstractRowResultDecoder(R) : RowDecoder {

    bool singleton;
    PgRowDesc desc;

    this(bool singleton, PgRowDesc desc) {
        this.singleton = singleton;
        this.desc = desc;
    }

    R complete();

    int size();

    void reset();
    
}

class RowResultDecoder(C, R) : AbstractRowResultDecoder!R {

    Collector!(Row, C, R) collector;
    BiConsumer!(C, Row) accumulator;

    private int size;
    private C container;
    private Row row;

    this(Collector!(Row, C, R) collector, bool singleton, PgRowDesc desc) {
        super(singleton, desc);

        this.collector = collector;
        this.accumulator = collector.accumulator();
    }

    override int size() {
        return size;
    }

    override
    void decodeRow(int len, ByteBuffer buffer) {
        if (container is null) {
            container = collector.supplier().get();
        }
        if (singleton) {
            if (row is null) {
                row = new RowImpl(desc);
            } else {
                row.clear();
            }
        } else {
            row = new RowImpl(desc);
        }
        Row row = new RowImpl(desc);
        for (int c = 0; c < len; ++c) {
            int length = buffer.readInt();
            Object decoded = null;
            if (length != -1) {
                PgColumnDesc columnDesc = desc.columns[c];
                if (columnDesc.dataFormat == DataFormat.BINARY) {
                    decoded = DataTypeCodec.decodeBinary(columnDesc.dataType, buffer.readerIndex(), length, buffer);
                } else {
                    decoded = DataTypeCodec.decodeText(columnDesc.dataType, buffer.readerIndex(), length, buffer);
                }
                buffer.skipBytes(length);
            }
            row.addValue(decoded);
        }
        accumulator.accept(container, row);
        size++;
    }

    override R complete() {
        if (container is null) {
            container = collector.supplier().get();
        }
        return collector.finisher().apply(container);
    }

    override void reset() {
        container = null;
        size = 0;
    }
}
