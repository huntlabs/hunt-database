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

module hunt.database.driver.postgresql.impl.codec.RowResultDecoder;

import hunt.database.driver.postgresql.impl.codec.DataFormat;
import hunt.database.driver.postgresql.impl.codec.DataType;
import hunt.database.driver.postgresql.impl.codec.DataTypeCodec;
import hunt.database.driver.postgresql.impl.codec.PgRowDesc;
import hunt.database.driver.postgresql.impl.codec.PgColumnDesc;
import hunt.database.driver.postgresql.impl.PostgreSQLRowImpl;

import hunt.database.base.Row;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.RowSetImpl;

import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;

import std.variant;

/**
 * 
 */
class RowResultDecoder(R) : RowDecoder {

    private int _size;
    private RowSetImpl container;
    private Row row;
    private bool singleton;
    PgRowDesc desc;

    this(bool singleton, PgRowDesc desc) {
        this.singleton = singleton;
        this.desc = desc;
    }

    int size() {
        return _size;
    }

    // override
    void decodeRow(int len, ByteBuf buffer) {
        if (container is null) {
            container = new RowSetImpl(); 
        }

        if (singleton) {
            if (row is null) {
                row = new PgRowImpl(desc);
            } else {
                row.clear();
            }
        } else {
            row = new PgRowImpl(desc);
        }

        version(HUNT_DB_DEBUG) infof("row: %d, size: %d", _size+1, len);
        
        Row row = new PgRowImpl(desc);
        for (int c = 0; c < len; ++c) {
            int length = buffer.readInt();
            Variant decoded = null;
            if (length != -1) {
                PgColumnDesc columnDesc = desc.columns[c];

                version(HUNT_DB_DEBUG_MORE) {
                    tracef("    column[%d]: name=%s, %s, dataFormat=%s", 
                       c, columnDesc.name, columnDesc.dataType, columnDesc.dataFormat);
                }

                if (columnDesc.dataFormat == DataFormat.BINARY) {
                    decoded = DataTypeCodec.decodeBinary(cast(DataType)columnDesc.dataType.id, 
                        buffer.readerIndex(), length, buffer);
                } else {
                    decoded = DataTypeCodec.decodeText(cast(DataType)columnDesc.dataType.id, 
                        buffer.readerIndex(), length, buffer);
                }

                version(HUNT_DB_DEBUG_MORE) {
                    tracef("    colum[%d]: value=%s", c,  decoded.toString());
                }

                buffer.skipBytes(length);
            }
            row.addValue(decoded);
        }
        container.append(row);
        _size++;
    }

    R complete() {
        if (container is null) {
            container = new RowSetImpl(); 
        }
        return container;
    }

    void reset() {
        container = null;
        _size = 0;
    }
}
