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

import hunt.database.postgresql.impl.codec.DataFormat;
import hunt.database.postgresql.impl.codec.DataType;
import hunt.database.postgresql.impl.codec.DataTypeCodec;
import hunt.database.postgresql.impl.codec.PgRowDesc;
import hunt.database.postgresql.impl.codec.PgColumnDesc;
// import hunt.database.postgresql.impl.codec.PgColumnDesc;

import hunt.database.base.Row;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.postgresql.impl.RowImpl;

import hunt.database.base.impl.RowDecoder;

// import java.util.function.BiConsumer;
// import java.util.stream.Collector;

import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;

/**
*/
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

/**
*/
class RowResultDecoder(R) : AbstractRowResultDecoder!R {

    private int _size;
    private RowSetImpl container;
    private Row row;

    this(bool singleton, PgRowDesc desc) {
        super(singleton, desc);
    }

    override int size() {
        return _size;
    }

    // override
    void decodeRow(int len, ByteBuf buffer) {
        if (container is null) {
            container = new RowSetImpl(); 
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
            string decoded = null;
            if (length != -1) {
                PgColumnDesc columnDesc = desc.columns[c];

                tracef("Column: name=%s, (%s), dataFormat=%s", 
                    columnDesc.name, columnDesc.dataType, columnDesc.dataFormat);

                if (columnDesc.dataFormat == DataFormat.BINARY) {
                    implementationMissing(false);
                    // decoded = DataTypeCodec.decodeBinary(cast(DataType)columnDesc.dataType.id, 
                    //     buffer.readerIndex(), length, buffer);
                } else {
                    decoded = DataTypeCodec.decodeText(cast(DataType)columnDesc.dataType.id, 
                        buffer.readerIndex(), length, buffer);
                }
                buffer.skipBytes(length);
            }
            row.addValue(decoded);
        }
        container.append(row);
        _size++;
    }

    override R complete() {
        if (container is null) {
            container = new RowSetImpl(); 
        }
        return container;
    }

    override void reset() {
        container = null;
        _size = 0;
    }
}
