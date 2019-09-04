module hunt.database.mysql.impl.codec.MySQLDecoder;

import hunt.database.mysql.impl.codec.CommandCodec;
import hunt.database.mysql.impl.codec.MySQLEncoder;
import hunt.database.mysql.impl.codec.Packets;

import hunt.database.base.impl.Notification;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.TxStatus;


import hunt.collection.ByteBuffer;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.codec.Decoder;
import hunt.net.Connection;
import hunt.net.buffer;

import std.container.dlist;
import std.conv;

class MySQLDecoder : Decoder {

    private DList!(CommandCodecBase) *inflight;
    private MySQLEncoder encoder;

    private CompositeByteBuf aggregatedPacketPayload = null;

    this(ref DList!(CommandCodecBase) inflight, MySQLEncoder encoder) {
        this.inflight = &inflight;
        this.encoder = encoder;
    }

    void decode(ByteBuffer msg, Connection connection) {
        ByteBuf inBuffer = Unpooled.wrappedBuffer(msg);
        if (inBuffer.readableBytes() > 4) {
            int packetStartIdx = inBuffer.readerIndex();
            int payloadLength = inBuffer.readUnsignedMediumLE();
            int sequenceId = inBuffer.readUnsignedByte();

            if (payloadLength >= Packets.PACKET_PAYLOAD_LENGTH_LIMIT && aggregatedPacketPayload is null) {
                aggregatedPacketPayload = Unpooled.compositeBuffer();
            }

            // payload
            if (inBuffer.readableBytes() >= payloadLength) {
                if (aggregatedPacketPayload !is null) {
                    // read a split packet
                    aggregatedPacketPayload.addComponent(true, inBuffer.readRetainedSlice(payloadLength));
                    sequenceId++;

                    if (payloadLength < Packets.PACKET_PAYLOAD_LENGTH_LIMIT) {
                        // we have just read the last split packet and there will be no more split packet
                        decodePayload(aggregatedPacketPayload, aggregatedPacketPayload.readableBytes(), sequenceId);
                        aggregatedPacketPayload.release();
                        aggregatedPacketPayload = null;
                    }
                } else {
                    // read a non-split packet
                    decodePayload(inBuffer.readSlice(payloadLength), payloadLength, sequenceId);
                }
            } else {
                inBuffer.readerIndex(packetStartIdx);
            }
        }
    }

    private void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        CommandCodecBase ctx = inflight.front();
        ctx.sequenceId = sequenceId + 1;
        ctx.decodePayload(payload, payloadLength, sequenceId);
        payload.clear();
    }
}
