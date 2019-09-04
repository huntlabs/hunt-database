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
module hunt.database.mysql.impl.codec.CommandCodec;

import hunt.database.mysql.impl.codec.CapabilitiesFlag;
import hunt.database.mysql.impl.codec.ColumnDefinition;
import hunt.database.mysql.impl.codec.DataType;
import hunt.database.mysql.impl.codec.MySQLEncoder;
// import hunt.database.mysql.impl.codec.NoticeResponse;
import hunt.database.mysql.impl.codec.Packets;

import hunt.database.mysql.MySQLException;
import hunt.database.mysql.impl.util.BufferUtils;

import hunt.database.base.Common;
import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandResponse;

import hunt.net.buffer;
import hunt.logging.ConsoleLogger;
import hunt.text.Charset;

/**
 * 
 */
abstract class CommandCodecBase {

    int sequenceId;
    MySQLEncoder encoder;
    Throwable failure;

    // EventHandler!(NoticeResponse) noticeHandler;
    EventHandler!(ICommandResponse) completionHandler;
    
    void encode(MySQLEncoder encoder);
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId);

    ICommand getCommand();
}

abstract class CommandCodec(R, C) : CommandCodecBase
        if(is(C : CommandBase!(R))) {

    R result;
    C cmd;
    private ByteBufAllocator alloc;

    this(C cmd) {
        this.cmd = cmd;
        alloc = UnpooledByteBufAllocator.DEFAULT();
    }

    override void encode(MySQLEncoder encoder) {
        this.encoder = encoder;
    }

    ByteBuf allocateBuffer() {
        return alloc.ioBuffer();
    }

    ByteBuf allocateBuffer(int capacity) {
        return alloc.ioBuffer(capacity);
    }

    void sendPacket(ByteBuf packet, int payloadLength) {
        if (payloadLength >= Packets.PACKET_PAYLOAD_LENGTH_LIMIT) {
            /*
                 The original packet exceeds the limit of packet length, split the packet here.
                 if payload length is exactly 16MBytes-1byte(0xFFFFFF), an empty packet is needed to indicate the termination.
             */
            sendSplitPacket(packet);
        } else {
            sendNonSplitPacket(packet);
        }
    }

    private void sendSplitPacket(ByteBuf packet) {
        ByteBuf payload = packet.skipBytes(4);
        while (payload.readableBytes() >= Packets.PACKET_PAYLOAD_LENGTH_LIMIT) {
            // send a packet with 0xFFFFFF length payload
            ByteBuf packetHeader = allocateBuffer(4);
            packetHeader.writeMediumLE(Packets.PACKET_PAYLOAD_LENGTH_LIMIT);
            packetHeader.writeByte(sequenceId++);
            encoder.write(packetHeader);
            encoder.write(payload.readRetainedSlice(Packets.PACKET_PAYLOAD_LENGTH_LIMIT));
        }

        // send a packet with last part of the payload
        ByteBuf packetHeader = allocateBuffer(4);
        packetHeader.writeMediumLE(payload.readableBytes());
        packetHeader.writeByte(sequenceId++);
        encoder.write(packetHeader);
        encoder.writeAndFlush(payload);
    }

    void sendNonSplitPacket(ByteBuf packet) {
        sequenceId++;
        encoder.writeAndFlush(packet);
    }

    void handleOkPacketOrErrorPacketPayload(ByteBuf payload) {
        Packets header = cast(Packets)payload.getUnsignedByte(payload.readerIndex());
        switch (header) {
            case Packets.EOF_PACKET_HEADER:
            case Packets.OK_PACKET_HEADER:
                if(completionHandler !is null) {
                    completionHandler(succeededResponse(cast(Object)null));
                }
                break;

            case Packets.ERROR_PACKET_HEADER:
                handleErrorPacketPayload(payload);
                break;
            
            default:
                warning("Can't handle Packets: %d", header);
                break;
        }
    }

    void handleErrorPacketPayload(ByteBuf payload) {
        payload.skipBytes(1); // skip ERR packet header
        int errorCode = payload.readUnsignedShortLE();
        string sqlState = null;
        if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_PROTOCOL_41) != 0) {
            payload.skipBytes(1); // SQL state marker will always be #
            sqlState = BufferUtils.readFixedLengthString(payload, 5, StandardCharsets.UTF_8);
        }
        string errorMessage = readRestOfPacketString(payload, StandardCharsets.UTF_8);

        if(completionHandler !is null) {
            completionHandler(failedResponse!Object(
                    new MySQLException(errorMessage, errorCode, sqlState)));
        }
        
    }

    OkPacket decodeOkPacketPayload(ByteBuf payload, Charset charset) {
        payload.skipBytes(1); // skip OK packet header
        long affectedRows = BufferUtils.readLengthEncodedInteger(payload);
        long lastInsertId = BufferUtils.readLengthEncodedInteger(payload);
        int serverStatusFlags = 0;
        int numberOfWarnings = 0;
        if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_PROTOCOL_41) != 0) {
            serverStatusFlags = payload.readUnsignedShortLE();
            numberOfWarnings = payload.readUnsignedShortLE();
        } else if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_TRANSACTIONS) != 0) {
            serverStatusFlags = payload.readUnsignedShortLE();
        }
        string statusInfo;
        string sessionStateInfo = null;
        if (payload.readableBytes() == 0) {
            // handle when OK packet does not contain server status info
            statusInfo = null;
        } else if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_SESSION_TRACK) != 0) {
            statusInfo = BufferUtils.readLengthEncodedString(payload, charset);
            if ((serverStatusFlags & ServerStatusFlags.SERVER_SESSION_STATE_CHANGED) != 0) {
                sessionStateInfo = BufferUtils.readLengthEncodedString(payload, charset);
            }
        } else {
            statusInfo = readRestOfPacketString(payload, charset);
        }
        return new OkPacket(affectedRows, lastInsertId, serverStatusFlags, numberOfWarnings, statusInfo, sessionStateInfo);
    }

    EofPacket decodeEofPacketPayload(ByteBuf payload) {
        payload.skipBytes(1); // skip EOF_Packet header
        int numberOfWarnings = payload.readUnsignedShortLE();
        int serverStatusFlags = payload.readUnsignedShortLE();
        return new EofPacket(numberOfWarnings, serverStatusFlags);
    }

    string readRestOfPacketString(ByteBuf payload, Charset charset) {
        return BufferUtils.readFixedLengthString(payload, payload.readableBytes(), charset);
    }

    ColumnDefinition decodeColumnDefinitionPacketPayload(ByteBuf payload) {
        string catalog = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        string schema = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        string table = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        string orgTable = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        string name = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        string orgName = BufferUtils.readLengthEncodedString(payload, StandardCharsets.UTF_8);
        long lengthOfFixedLengthFields = BufferUtils.readLengthEncodedInteger(payload);
        int characterSet = payload.readUnsignedShortLE();
        long columnLength = payload.readUnsignedIntLE();
        DataType type = cast(DataType)payload.readUnsignedByte();
        int flags = payload.readUnsignedShortLE();
        byte decimals = payload.readByte();
        return new ColumnDefinition(catalog, schema, table, orgTable, name, orgName, 
            characterSet, columnLength, type, flags, decimals);
    }

    void skipEofPacketIfNeeded(ByteBuf payload) {
        if (!isDeprecatingEofFlagEnabled()) {
            payload.skipBytes(5);
        }
    }

    bool isDeprecatingEofFlagEnabled() {
        return (encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_DEPRECATE_EOF) != 0;
    }
    
    override C getCommand() {
        return cmd;
    }
}
