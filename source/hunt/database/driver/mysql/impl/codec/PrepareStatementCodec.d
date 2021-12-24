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
module hunt.database.driver.mysql.impl.codec.PrepareStatementCodec;

import hunt.database.driver.mysql.impl.codec.ColumnDefinition;
import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.CommandType;
import hunt.database.driver.mysql.impl.codec.DataFormat;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;
import hunt.database.driver.mysql.impl.codec.MySQLParamDesc;
import hunt.database.driver.mysql.impl.codec.MySQLRowDesc;
import hunt.database.driver.mysql.impl.codec.MySQLPreparedStatement;
import hunt.database.driver.mysql.impl.codec.Packets;

import hunt.net.buffer.ByteBuf;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.PrepareStatementCommand;

import hunt.logging;
import hunt.Exceptions;
import hunt.text.Charset;

/**
 * 
 */
class PrepareStatementCodec : CommandCodec!(PreparedStatement, PrepareStatementCommand) {

    private CommandHandlerState commandHandlerState = CommandHandlerState.INIT;
    private long statementId;
    private int processingIndex;
    private ColumnDefinition[] paramDescs;
    private ColumnDefinition[] columnDescs;

    this(PrepareStatementCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendStatementPrepareCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        switch (commandHandlerState) {
            case CommandHandlerState.INIT:
                int firstByte = payload.getUnsignedByte(payload.readerIndex());
                if (firstByte == Packets.ERROR_PACKET_HEADER) {
                    handleErrorPacketPayload(payload);
                } else {
                    // handle COM_STMT_PREPARE response
                    payload.readUnsignedByte(); // 0x00: OK
                    long statementId = payload.readUnsignedIntLE();
                    int numberOfColumns = payload.readUnsignedShortLE();
                    int numberOfParameters = payload.readUnsignedShortLE();
                    payload.readByte(); // [00] filler
                    int numberOfWarnings = payload.readShortLE();

                    // handle metadata here
                    this.statementId = statementId;
                    this.paramDescs = new ColumnDefinition[numberOfParameters];
                    this.columnDescs = new ColumnDefinition[numberOfColumns];

                    if (numberOfParameters != 0) {
                        processingIndex = 0;
                        this.commandHandlerState = CommandHandlerState.HANDLING_PARAM_COLUMN_DEFINITION;
                    } else if (numberOfColumns != 0) {
                        processingIndex = 0;
                        this.commandHandlerState = CommandHandlerState.HANDLING_COLUMN_COLUMN_DEFINITION;
                    } else {
                        handleReadyForQuery();
                        resetIntermediaryResult();
                    }
                }
                break;
            case CommandHandlerState.HANDLING_PARAM_COLUMN_DEFINITION:
                paramDescs[processingIndex++] = decodeColumnDefinitionPacketPayload(payload);
                if (processingIndex == paramDescs.length) {
                    if (isDeprecatingEofFlagEnabled()) {
                        // we enabled the DEPRECATED_EOF flag and don't need to accept an EOF_Packet
                        handleParamDefinitionsDecodingCompleted();
                    } else {
                        // we need to decode an EOF_Packet before handling rows, to be compatible with MySQL version below 5.7.5
                        commandHandlerState = CommandHandlerState.PARAM_DEFINITIONS_DECODING_COMPLETED;
                    }
                }
                break;
            case CommandHandlerState.PARAM_DEFINITIONS_DECODING_COMPLETED:
                skipEofPacketIfNeeded(payload);
                handleParamDefinitionsDecodingCompleted();
                break;
            case CommandHandlerState.HANDLING_COLUMN_COLUMN_DEFINITION:
                columnDescs[processingIndex++] = decodeColumnDefinitionPacketPayload(payload);
                if (processingIndex == columnDescs.length) {
                    if (isDeprecatingEofFlagEnabled()) {
                        // we enabled the DEPRECATED_EOF flag and don't need to accept an EOF_Packet
                        handleColumnDefinitionsDecodingCompleted();
                    } else {
                        // we need to decode an EOF_Packet before handling rows, to be compatible with MySQL version below 5.7.5
                        commandHandlerState = CommandHandlerState.COLUMN_DEFINITIONS_DECODING_COMPLETED;
                    }
                }
                break;
            case CommandHandlerState.COLUMN_DEFINITIONS_DECODING_COMPLETED:
                handleColumnDefinitionsDecodingCompleted();
                break;

            default:
                warningf("Unhandled state: %d", commandHandlerState);
                break;
        }
    }

    private void sendStatementPrepareCommand() {
        ByteBuf packet = allocateBuffer();
        // encode packet header
        int packetStartIdx = packet.writerIndex();
        packet.writeMediumLE(0); // will set payload length later by calculation
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_STMT_PREPARE);
        packet.writeCharSequence(cmd.sql(), StandardCharsets.UTF_8);

        // set payload length
        int payloadLength = packet.writerIndex() - packetStartIdx - 4;
        packet.setMediumLE(packetStartIdx, payloadLength);

        sendPacket(packet, payloadLength);
    }

    private void handleReadyForQuery() {
        if(completionHandler !is null) {
            completionHandler(succeededResponse!(PreparedStatement)(new MySQLPreparedStatement(
                cmd.sql(),
                this.statementId,
                new MySQLParamDesc(paramDescs),
                new MySQLRowDesc(columnDescs, DataFormat.BINARY))));
        }
    }

    private void resetIntermediaryResult() {
        commandHandlerState = CommandHandlerState.INIT;
        statementId = 0;
        processingIndex = 0;
        paramDescs = null;
        columnDescs = null;
    }

    private void handleParamDefinitionsDecodingCompleted() {
        if (columnDescs.length == 0) {
            handleReadyForQuery();
            resetIntermediaryResult();
        } else {
            processingIndex = 0;
            this.commandHandlerState = CommandHandlerState.HANDLING_COLUMN_COLUMN_DEFINITION;
        }
    }

    private void handleColumnDefinitionsDecodingCompleted() {
        handleReadyForQuery();
        resetIntermediaryResult();
    }

}


private enum CommandHandlerState {
    INIT,
    HANDLING_PARAM_COLUMN_DEFINITION,
    PARAM_DEFINITIONS_DECODING_COMPLETED,
    HANDLING_COLUMN_COLUMN_DEFINITION,
    COLUMN_DEFINITIONS_DECODING_COMPLETED
}