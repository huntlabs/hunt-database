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
module hunt.database.driver.mysql.impl.codec.SimpleQueryCommandCodec;

import hunt.database.driver.mysql.impl.codec.CommandType;
import hunt.database.driver.mysql.impl.codec.DataFormat;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;
import hunt.database.driver.mysql.impl.codec.Packets;
import hunt.database.driver.mysql.impl.codec.QueryCommandBaseCodec;

import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.SimpleQueryCommand;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer.ByteBuf;
import hunt.text.Charset;

/**
 * 
 */
class SimpleQueryCommandCodec(T) : QueryCommandBaseCodec!(T, SimpleQueryCommand!(T)) {

    this(SimpleQueryCommand!(T) cmd) {
        super(cmd, DataFormat.TEXT);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendQueryCommand();
    }

    override
    protected void handleInitPacket(ByteBuf payload) {
        // may receive ERR_Packet, OK_Packet, LOCAL INFILE Request, Text Resultset
        int firstByte = payload.getUnsignedByte(payload.readerIndex());
        tracef("firstByte: %d", firstByte);
        if (firstByte == Packets.OK_PACKET_HEADER) {
            OkPacket okPacket = decodeOkPacketPayload(payload, StandardCharsets.UTF_8);
            handleSingleResultsetDecodingCompleted(okPacket.serverStatusFlags(),
                cast(int) okPacket.affectedRows(), cast(int) okPacket.lastInsertId());
        } else if (firstByte == Packets.ERROR_PACKET_HEADER) {
            handleErrorPacketPayload(payload);
        } else if (firstByte == 0xFB) {
            //TODO LOCAL INFILE Request support
            if(completionHandler !is null) {
                completionHandler(failedResponse!(ICommandResponse)(
                        new UnsupportedOperationException("LOCAL INFILE is not supported for now")));
            }
        } else {
            handleResultsetColumnCountPacketBody(payload);
        }
    }

    private void sendQueryCommand() {
        ByteBuf packet = allocateBuffer();
        // encode packet header
        int packetStartIdx = packet.writerIndex();
        packet.writeMediumLE(0); // will set payload length later by calculation
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_QUERY);
        version(HUNT_DB_DEBUG) {
            tracef("%s", cmd.sql());
        }
        packet.writeCharSequence(cmd.sql(), StandardCharsets.UTF_8);

        // set payload length
        int payloadLength = packet.writerIndex() - packetStartIdx - 4;
        packet.setMediumLE(packetStartIdx, payloadLength);

        sendPacket(packet, payloadLength);
    }
}
