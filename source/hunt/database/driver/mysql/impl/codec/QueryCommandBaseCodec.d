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
module hunt.database.driver.mysql.impl.codec.QueryCommandBaseCodec;

import hunt.database.driver.mysql.impl.codec.ColumnDefinition;
import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.DataFormat;
import hunt.database.driver.mysql.impl.codec.MySQLRowDesc;
import hunt.database.driver.mysql.impl.codec.Packets;
import hunt.database.driver.mysql.impl.codec.RowResultDecoder;

import hunt.database.driver.mysql.MySQLClient;
import hunt.database.driver.mysql.impl.util.BufferUtils;

import hunt.database.base.Row;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.RowSetImpl;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.QueryCommandBase;

import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;

import std.variant;

/**
 * 
 */
abstract class QueryCommandBaseCodec(T, C) : CommandCodec!(bool, C) {
    // C extends QueryCommandBase!(T)

    private DataFormat format;

    protected CommandHandlerState commandHandlerState = CommandHandlerState.INIT;
    protected ColumnDefinition[] columnDefinitions;
    // protected RowResultDecoder<?, T> decoder;
    protected RowResultDecoder!T decoder;
    private int currentColumn;

    this(C cmd, DataFormat format) {
        super(cmd);
        this.format = format;
    }

    // private static <A, T> T emptyResult(Collector!(Row, A, T) collector) {
    //     return collector.finisher().apply(collector.supplier().get());
    // }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        version(HUNT_DB_DEBUG_MORE) infof("commandHandlerState: %s", commandHandlerState);
        switch (commandHandlerState) {
            case CommandHandlerState.INIT:
                handleInitPacket(payload);
                break;
            case CommandHandlerState.HANDLING_COLUMN_DEFINITION:
                handleResultsetColumnDefinitions(payload);
                break;
            case CommandHandlerState.COLUMN_DEFINITIONS_DECODING_COMPLETED:
                skipEofPacketIfNeeded(payload);
                handleResultsetColumnDefinitionsDecodingCompleted();
                break;
            case CommandHandlerState.HANDLING_ROW_DATA_OR_END_PACKET:
                handleRows(payload, payloadLength, &handleSingleRow);
                break;
            default:
                warningf("Unhandled state: %d", commandHandlerState);
                break;
        }
    }

    protected abstract void handleInitPacket(ByteBuf payload);

    protected void handleResultsetColumnCountPacketBody(ByteBuf payload) {
        int columnCount = decodeColumnCountPacketPayload(payload);
        commandHandlerState = CommandHandlerState.HANDLING_COLUMN_DEFINITION;
        columnDefinitions = new ColumnDefinition[columnCount];
    }

    protected void handleResultsetColumnDefinitions(ByteBuf payload) {
        ColumnDefinition def = decodeColumnDefinitionPacketPayload(payload);
        columnDefinitions[currentColumn++] = def;
        if (currentColumn == columnDefinitions.length) {
            // all column definitions have been decoded, switch to column definitions decoding completed state
            if (isDeprecatingEofFlagEnabled()) {
                // we enabled the DEPRECATED_EOF flag and don't need to accept an EOF_Packet
                handleResultsetColumnDefinitionsDecodingCompleted();
            } else {
                // we need to decode an EOF_Packet before handling rows, to be compatible with MySQL version below 5.7.5
                commandHandlerState = CommandHandlerState.COLUMN_DEFINITIONS_DECODING_COMPLETED;
            }
        }
    }

    protected void handleResultsetColumnDefinitionsDecodingCompleted() {
        commandHandlerState = CommandHandlerState.HANDLING_ROW_DATA_OR_END_PACKET;
        decoder = new RowResultDecoder!(T)(false/*cmd.isSingleton()*/, new MySQLRowDesc(columnDefinitions, format));
    }

    protected void handleRows(ByteBuf payload, int payloadLength, Consumer!(ByteBuf) singleRowHandler) {
    /*
        Resultset row can begin with 0xfe byte (when using text protocol with a field length > 0xffffff)
        To ensure that packets beginning with 0xfe correspond to the ending packet (EOF_Packet or OK_Packet with a 0xFE header),
        the packet length must be checked and must be less than 0xffffff in length.
     */
        int first = payload.getUnsignedByte(payload.readerIndex());
        if (first == Packets.ERROR_PACKET_HEADER) {
            handleErrorPacketPayload(payload);
        }
        // enabling CLIENT_DEPRECATE_EOF capability will receive an OK_Packet with a EOF_Packet header here
        // we need check this is not a row data by checking packet length < 0xFFFFFF
        else if (first == Packets.EOF_PACKET_HEADER && payloadLength < 0xFFFFFF) {
            int serverStatusFlags;
            int affectedRows = -1;
            int lastInsertId = -1;
            if (isDeprecatingEofFlagEnabled()) {
                OkPacket okPacket = decodeOkPacketPayload(payload, StandardCharsets.UTF_8);
                serverStatusFlags = okPacket.serverStatusFlags();
                affectedRows = cast(int) okPacket.affectedRows();
                lastInsertId = cast(int) okPacket.lastInsertId();
            } else {
                serverStatusFlags = decodeEofPacketPayload(payload).serverStatusFlags();
            }
            handleSingleResultsetDecodingCompleted(serverStatusFlags, affectedRows, lastInsertId);
        } else {
            if(singleRowHandler !is null) {
                singleRowHandler(payload);
            }
        }
    }

    protected void handleSingleRow(ByteBuf payload) {
        // accept a row data
        decoder.decodeRow(cast(int)columnDefinitions.length, payload);
    }

    protected void handleSingleResultsetDecodingCompleted(int serverStatusFlags, 
            int affectedRows, int lastInsertId) {
        handleSingleResultsetEndPacket(serverStatusFlags, affectedRows, lastInsertId);
        resetIntermediaryResult();
        if (isDecodingCompleted(serverStatusFlags)) {
            // no more sql result
            handleAllResultsetDecodingCompleted();
        }
    }

    protected bool isDecodingCompleted(int serverStatusFlags) {
        return (serverStatusFlags & ServerStatusFlags.SERVER_MORE_RESULTS_EXISTS) == 0;
    }

    private void handleSingleResultsetEndPacket(int serverStatusFlags, int affectedRows, int lastInsertId) {
        this.result = (serverStatusFlags & ServerStatusFlags.SERVER_STATUS_LAST_ROW_SENT) == 0;
        T result;
        int size;
        RowDesc rowDesc;
        if (decoder !is null) {
            result = decoder.complete();
            rowDesc = decoder.rowDesc;
            size = decoder.size();
            decoder.reset();
        } else {
            result = new RowSetImpl(); 
            size = 0;
            rowDesc = null;
        }
        version(HUNT_DB_DEBUG_MORE) infof("size=%d, affectedRows=%d", size, affectedRows);

        // MySQL returns affected rows as 0 for SELECT query but Postgres returns queried amount
        if(affectedRows == -1)
            affectedRows = size;
        
        cmd.resultHandler().handleResult(affectedRows, size, rowDesc, result);
        Variant v = Variant(lastInsertId);
        cmd.resultHandler().addProperty(MySQLClient.LAST_INSERTED_ID, v);
    }

    private void handleAllResultsetDecodingCompleted() {
        CommandResponse!(bool) response;
        if (this.failure !is null) {
            response = failedResponse!bool(this.failure);
        } else {
            response = succeededResponse(this.result);
        }

        if(completionHandler !is null) {
            completionHandler(response);
        }
    }

    private int decodeColumnCountPacketPayload(ByteBuf payload) {
        long columnCount = BufferUtils.readLengthEncodedInteger(payload);
        return cast(int) columnCount;
    }

    private void resetIntermediaryResult() {
        commandHandlerState = CommandHandlerState.INIT;
        columnDefinitions = null;
        currentColumn = 0;
    }

}

enum CommandHandlerState {
    INIT,
    HANDLING_COLUMN_DEFINITION,
    COLUMN_DEFINITIONS_DECODING_COMPLETED,
    HANDLING_ROW_DATA_OR_END_PACKET
}