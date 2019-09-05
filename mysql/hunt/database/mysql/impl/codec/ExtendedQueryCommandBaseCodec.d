module hunt.database.mysql.impl.codec.ExtendedQueryCommandBaseCodec;

import hunt.database.mysql.impl.codec.ColumnDefinition;
import hunt.database.mysql.impl.codec.CommandType;
import hunt.database.mysql.impl.codec.DataFormat;
import hunt.database.mysql.impl.codec.DataType;
import hunt.database.mysql.impl.codec.DataTypeCodec;
import hunt.database.mysql.impl.codec.MySQLPreparedStatement;
import hunt.database.mysql.impl.codec.Packets;
import hunt.database.mysql.impl.codec.QueryCommandBaseCodec;

import hunt.database.mysql.impl.MySQLCollation;
import hunt.database.base.Tuple;
import hunt.database.base.impl.command.ExtendedQueryCommandBase;

import hunt.Exceptions;
import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;
// import java.time.Duration;
// import java.time.LocalDate;
// import java.time.LocalDateTime;

import std.variant;

/**
 * 
 */
abstract class ExtendedQueryCommandBaseCodec(R, C) : QueryCommandBaseCodec!(R, C) {
        // C extends ExtendedQueryCommandBase!(R)
    // TODO handle re-bound situations?
    // Flag if parameters must be re-bound
    protected byte sendType = 1;

    protected MySQLPreparedStatement statement;

    this(C cmd) {
        super(cmd, DataFormat.BINARY);
        statement = cast(MySQLPreparedStatement) cmd.preparedStatement();
    }

    override
    protected void handleInitPacket(ByteBuf payload) {
        // may receive ERR_Packet, OK_Packet, Binary Protocol Resultset
        int firstByte = payload.getUnsignedByte(payload.readerIndex());
        if (firstByte == Packets.OK_PACKET_HEADER) {
            OkPacket okPacket = decodeOkPacketPayload(payload, StandardCharsets.UTF_8);
            handleSingleResultsetDecodingCompleted(okPacket.serverStatusFlags(), 
                cast(int) okPacket.affectedRows(), cast(int) okPacket.lastInsertId());
        } else if (firstByte == Packets.ERROR_PACKET_HEADER) {
            handleErrorPacketPayload(payload);
        } else {
            handleResultsetColumnCountPacketBody(payload);
        }
    }

    protected void sendStatementExecuteCommand(long statementId, ColumnDefinition[] paramsColumnDefinitions, 
                byte sendType, Tuple params, byte cursorType) {
        ByteBuf packet = allocateBuffer();
        // encode packet header
        int packetStartIdx = packet.writerIndex();
        packet.writeMediumLE(0); // will set payload length later by calculation
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_STMT_EXECUTE);
        packet.writeIntLE(cast(int) statementId);
        packet.writeByte(cursorType);
        // iteration count, always 1
        packet.writeIntLE(1);

        int numOfParams = cast(int)paramsColumnDefinitions.length;
        int bitmapLength = (numOfParams + 7) / 8;
        byte[] nullBitmap = new byte[bitmapLength];

        int pos = packet.writerIndex();

        if (numOfParams > 0) {
            // write a dummy bitmap first
            packet.writeBytes(nullBitmap);
            packet.writeByte(sendType);
            if (sendType == 1) {
                for (int i = 0; i < numOfParams; i++) {
                    Variant value = params.getValue(i);
                    implementationMissing(false);
                    // packet.writeByte(parseDataTypeByEncodingValue(value).id);
                    packet.writeByte(0); // parameter flag: signed
                }
            }

            for (int i = 0; i < numOfParams; i++) {
                Variant value = params.getValue(i);
                if (value.hasValue() && value != null) {
                    MySQLCollation collation = MySQLCollation.valueOfId(paramsColumnDefinitions[i].characterSet());
                    DataTypeCodec.encodeBinary(parseDataTypeByEncodingValue(value),
                        (collation.mappedCharsetName()), value, packet); // Charset.forName
                } else {
                    nullBitmap[i / 8] |= (1 << (i & 7));
                }
            }

            // padding null-bitmap content
            packet.setBytes(pos, nullBitmap);
        }

        // set payload length
        int payloadLength = packet.writerIndex() - packetStartIdx - 4;
        packet.setMediumLE(packetStartIdx, payloadLength);

        sendPacket(packet, payloadLength);
    }

    private DataType parseDataTypeByEncodingValue(ref Variant value) {
        implementationMissing(false);
        return DataType.NULL;
        // if (value is null) {
        //     // ProtocolBinary::MYSQL_TYPE_NULL
        //     return DataType.NULL;
        // } else if (value instanceof Byte) {
        //     // ProtocolBinary::MYSQL_TYPE_TINY
        //     return DataType.INT1;
        // } else if (value instanceof Boolean) {
        //     // ProtocolBinary::MYSQL_TYPE_TINY
        //     return DataType.INT1;
        // } else if (value instanceof Short) {
        //     // ProtocolBinary::MYSQL_TYPE_SHORT, ProtocolBinary::MYSQL_TYPE_YEAR
        //     return DataType.INT2;
        // } else if (value instanceof Integer) {
        //     // ProtocolBinary::MYSQL_TYPE_LONG, ProtocolBinary::MYSQL_TYPE_INT24
        //     return DataType.INT4;
        // } else if (value instanceof Long) {
        //     // ProtocolBinary::MYSQL_TYPE_LONGLONG
        //     return DataType.INT8;
        // } else if (value instanceof Double) {
        //     // ProtocolBinary::MYSQL_TYPE_DOUBLE
        //     return DataType.DOUBLE;
        // } else if (value instanceof Float) {
        //     // ProtocolBinary::MYSQL_TYPE_FLOAT
        //     return DataType.FLOAT;
        // } else if (value instanceof LocalDate) {
        //     // ProtocolBinary::MYSQL_TYPE_DATE
        //     return DataType.DATE;
        // } else if (value instanceof Duration) {
        //     // ProtocolBinary::MYSQL_TYPE_TIME
        //     return DataType.TIME;
        // } else if (value instanceof Buffer) {
        //     // ProtocolBinary::MYSQL_TYPE_LONG_BLOB, ProtocolBinary::MYSQL_TYPE_MEDIUM_BLOB, ProtocolBinary::MYSQL_TYPE_BLOB, ProtocolBinary::MYSQL_TYPE_TINY_BLOB
        //     return DataType.BLOB;
        // } else if (value instanceof LocalDateTime) {
        //     // ProtocolBinary::MYSQL_TYPE_DATETIME, ProtocolBinary::MYSQL_TYPE_TIMESTAMP
        //     return DataType.DATETIME;
        // } else {
        //     /*
        //         ProtocolBinary::MYSQL_TYPE_STRING, ProtocolBinary::MYSQL_TYPE_VARCHAR, ProtocolBinary::MYSQL_TYPE_VAR_STRING,
        //         ProtocolBinary::MYSQL_TYPE_ENUM, ProtocolBinary::MYSQL_TYPE_SET, ProtocolBinary::MYSQL_TYPE_GEOMETRY,
        //         ProtocolBinary::MYSQL_TYPE_BIT, ProtocolBinary::MYSQL_TYPE_DECIMAL, ProtocolBinary::MYSQL_TYPE_NEWDECIMAL
        //      */
        //     return DataType.STRING;
        // }
    }
}
