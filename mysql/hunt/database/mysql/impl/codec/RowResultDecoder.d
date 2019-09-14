module hunt.database.mysql.impl.codec.RowResultDecoder;

import hunt.database.mysql.impl.codec.CommandCodec;
import hunt.database.mysql.impl.codec.ColumnDefinition;
import hunt.database.mysql.impl.codec.CommandType;
import hunt.database.mysql.impl.codec.DataFormat;
import hunt.database.mysql.impl.codec.DataType;
import hunt.database.mysql.impl.codec.DataTypeCodec;
import hunt.database.mysql.impl.codec.MySQLEncoder;
import hunt.database.mysql.impl.codec.MySQLRowDesc;
import hunt.database.mysql.impl.codec.Packets;

import hunt.database.mysql.impl.MySQLCollation;
import hunt.database.mysql.impl.MySQLRowImpl;

import hunt.database.base.Row;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.RowSetImpl;

import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;

import std.variant;


/**
 * 
 */
class RowResultDecoder(R) : RowDecoder {
    private enum int NULL = 0xFB;

    private int _size;
    private RowSetImpl container;
    private Row row;
    private bool singleton;
    MySQLRowDesc rowDesc;

    this(bool singleton, MySQLRowDesc rowDesc) {
        this.singleton = singleton;
        this.rowDesc = rowDesc;
    }

    int size() {
        return _size;
    }

    override
    void decodeRow(int len, ByteBuf inBuffer) {
        if (container is null) {
            container = new RowSetImpl(); 
        }

        if (singleton) {
            if (row is null) {
                row = new MySQLRowImpl(rowDesc);
            } else {
                row.clear();
            }
        } else {
            row = new MySQLRowImpl(rowDesc);
        }

        version(HUNT_DB_DEBUG) infof("row: %d", _size+1);
        Row row = new MySQLRowImpl(rowDesc);
        if (rowDesc.dataFormat() == DataFormat.BINARY) {
            // BINARY row decoding
            // 0x00 packet header
            // null_bitmap
            int nullBitmapLength = (len + 7 + 2) >>  3;
            int nullBitmapIdx = 1 + inBuffer.readerIndex();
            inBuffer.skipBytes(1 + nullBitmapLength);

            // values
            for (int c = 0; c < len; c++) {
                int val = c + 2;
                int bytePos = val >> 3;
                int bitPos = val & 7;
                byte mask = cast(byte) (1 << bitPos);
                byte nullByte = cast(byte) (inBuffer.getByte(nullBitmapIdx + bytePos) & mask);
                Variant decoded = null;
                if (nullByte == 0) {
                    // non-null
                    ColumnDefinition columnDesc = rowDesc.columnDefinitions()[c];
                    DataType dataType = columnDesc.type();
                    int collationId = rowDesc.columnDefinitions()[c].characterSet();
                    Charset charset = (MySQLCollation.valueOfId(collationId).mappedCharsetName()); // Charset.forName
                    int columnDefinitionFlags = columnDesc.flags();

                    version(HUNT_DB_DEBUG_MORE) {
                        tracef("    column[%d]: name=%s, type=%s, flags=%d, charset=%s", 
                            c, columnDesc.name(), dataType, columnDefinitionFlags, charset);
                    }

                    decoded = DataTypeCodec.decodeBinary(dataType, charset, columnDefinitionFlags, inBuffer);
                    
                    version(HUNT_DB_DEBUG_MORE) {
                        tracef("    column[%d]: value=%s", c, decoded.toString());
                    }
                }
                row.addValue(decoded);
            }
        } else {
            // TEXT row decoding
            for (int c = 0; c < len; c++) {
                Variant decoded = null;
                if (inBuffer.getUnsignedByte(inBuffer.readerIndex()) == NULL) {
                    inBuffer.skipBytes(1);
                } else {
                    ColumnDefinition columnDesc = rowDesc.columnDefinitions()[c];
                    
                    DataType dataType = columnDesc.type();
                    int columnDefinitionFlags = columnDesc.flags();
                    int collationId = columnDesc.characterSet();
                    Charset charset = (MySQLCollation.valueOfId(collationId).mappedCharsetName()); // Charset.forName

                    version(HUNT_DB_DEBUG_MORE) {
                        tracef("    column[%d]: name=%s, type=%s, flags=%d, charset=%s", 
                            c, columnDesc.name(), dataType, columnDefinitionFlags, charset);
                    }

                    decoded = DataTypeCodec.decodeText(dataType, charset, columnDefinitionFlags, inBuffer);

                    version(HUNT_DB_DEBUG_MORE) {
                        tracef("    colum[%d]: value=%s", c, decoded.toString());
                    }
                }
                row.addValue(decoded);
            }
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

