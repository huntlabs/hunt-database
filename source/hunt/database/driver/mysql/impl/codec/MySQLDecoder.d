module hunt.database.driver.mysql.impl.codec.MySQLDecoder;

import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;
import hunt.database.driver.mysql.impl.codec.Packets;

import hunt.database.base.impl.Notification;
import hunt.database.base.impl.RowDecoder;
import hunt.database.base.impl.TxStatus;


import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.io.channel;
import hunt.logging;
import hunt.net.codec.Decoder;
import hunt.net.Connection;
import hunt.net.buffer;

import std.container.dlist;
import std.conv;

class MySQLDecoder : Decoder {

    private ByteBufAllocator alloc;
    private DList!(CommandCodecBase) *inflight;
    private ByteBuf inBuffer;
    private MySQLEncoder encoder;

    private CompositeByteBuf aggregatedPacketPayload = null;

    this(ref DList!(CommandCodecBase) inflight, MySQLEncoder encoder) {
        this.inflight = &inflight;
        this.encoder = encoder;
        alloc = UnpooledByteBufAllocator.DEFAULT();
    }

    DataHandleStatus decode(ByteBuffer payload, Connection connection) {
        DataHandleStatus resultStatus = DataHandleStatus.Done;
        try {
            resultStatus = doEecode(payload, connection);
        } catch(Exception ex) {
            BufferUtils.clear(payload);
            version(HUNT_DEBUG) warning(ex);
            else warning(ex.msg);
        }

        return resultStatus;
    }

    private DataHandleStatus doEecode(ByteBuffer payload, Connection connection) {
        version(HUNT_DB_DEBUG_MORE) tracef("decoding buffer: %s", payload.toString());
        DataHandleStatus resultStatus = DataHandleStatus.Done;

        ByteBuf buff = Unpooled.wrappedBuffer(payload);
        if (inBuffer is null) {
            inBuffer = buff;
        } else {
            CompositeByteBuf composite = cast(CompositeByteBuf) inBuffer;
            if (composite is null) {
                composite = alloc.compositeBuffer();
                composite.addComponent(true, inBuffer);
                inBuffer = composite;
            }
            composite.addComponent(true, buff);
        }

        while (true) {
            int available = inBuffer.readableBytes();
            if (available < 4) { // no enough bytes available in buffer
                break;
            }

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
                // Need more bytes, so buffer them first.
                version(HUNT_DB_DEBUG_MORE) warning("Remaining: ", inBuffer.toString());
                break;
            }

        }

        if (inBuffer !is null) {
            if(inBuffer.isReadable()) {
                // copy the remainings in current buffer
                version(HUNT_DB_DEBUG_MORE) warningf("copying the remaings: %s", inBuffer.toString());
                inBuffer = inBuffer.copy();
            } else {
                // clear up the buffer
                inBuffer.release();
                inBuffer = null;
            }
        }

        return resultStatus;          
    }

    private void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        // if(inflight.empty()) {
        //      warning("inflight is empty.");
        //      return;
        // }
        while(inflight.empty()) {
            version(HUNT_DB_DEBUG_MORE) warning("inflight is empty.");
        }
        CommandCodecBase ctx = inflight.front();
        version(HUNT_DB_DEBUG_MORE) {
            tracef("Command codec: %s", typeid(ctx));
            // tracef("length: %d, payload: %s", payloadLength, payload.toString());
        }
        ctx.sequenceId = sequenceId + 1;
        ctx.decodePayload(payload, payloadLength, sequenceId);
        payload.clear();
    }
}
