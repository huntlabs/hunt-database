module hunt.database.mysql.impl.codec.ChangeUserCommandCodec;

import hunt.database.mysql.impl.codec.CapabilitiesFlag;
import hunt.database.mysql.impl.codec.CommandCodec;
import hunt.database.mysql.impl.codec.CommandType;
import hunt.database.mysql.impl.codec.MySQLEncoder;
import hunt.database.mysql.impl.codec.Packets;

import hunt.database.mysql.impl.MySQLCollation;
import hunt.database.mysql.impl.command.ChangeUserCommand;
import hunt.database.mysql.impl.util.BufferUtils;
import hunt.database.mysql.impl.util.Native41Authenticator;
import hunt.database.base.impl.command.CommandResponse;

import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer;
import hunt.Object;
import hunt.text.Charset;

import std.array;

/**
 * 
 */
class ChangeUserCommandCodec : CommandCodec!(Void, ChangeUserCommand) {
    this(ChangeUserCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendChangeUserCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        Packets header = cast(Packets)payload.getUnsignedByte(payload.readerIndex());
        switch (header) {
            case Packets.EOF_PACKET_HEADER: // 0xFE
                string pluginName = BufferUtils.readNullTerminatedString(payload, StandardCharsets.UTF_8);
                if (pluginName == "caching_sha2_password") {
                    // TODO support different auth methods later
                    completionHandler(failedResponse!(Void)(new 
                        UnsupportedOperationException("unsupported authentication method: " ~ pluginName)));
                    return;
                }
                byte[] scramble = new byte[20];
                payload.readBytes(scramble);
                byte[] scrambledPassword = Native41Authenticator.encode(cmd.password(), StandardCharsets.UTF_8, scramble);
                sendAuthSwitchResponse(scrambledPassword);
                break;
            case Packets.OK_PACKET_HEADER:
                completionHandler(succeededResponse(cast(Void)null));
                break;
            case Packets.ERROR_PACKET_HEADER:
                handleErrorPacketPayload(payload);
                break;
            
            default:
                warningf("Can't handle %d", header);
                break;
        }
    }

    private void sendChangeUserCommand() {
        ByteBuf packet = allocateBuffer();
        // encode packet header
        int packetStartIdx = packet.writerIndex();
        packet.writeMediumLE(0); // will set payload length later by calculation
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_CHANGE_USER);
        BufferUtils.writeNullTerminatedString(packet, cmd.username(), StandardCharsets.UTF_8);
        string password = cmd.password();
        if (password.empty()) {
            packet.writeByte(0);
        } else {
            packet.writeByte(cast(int)password.length);
            packet.writeCharSequence(password, StandardCharsets.UTF_8);
        }
        BufferUtils.writeNullTerminatedString(packet, cmd.database(), StandardCharsets.UTF_8);
        MySQLCollation collation = cmd.collation();
        int collationId = collation.collationId();
        encoder.charset = collation.mappedJavaCharsetName(); // Charset.forName(collation.mappedJavaCharsetName());
        packet.writeShortLE(collationId);

        if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_PLUGIN_AUTH) != 0) {
            BufferUtils.writeNullTerminatedString(packet, "mysql_native_password", StandardCharsets.UTF_8);
        }
        Map!(string, string) clientConnectionAttributes = cmd.connectionAttributes();
        if (clientConnectionAttributes !is null && !clientConnectionAttributes.isEmpty()) {
            encoder.clientCapabilitiesFlag |= CapabilitiesFlag.CLIENT_CONNECT_ATTRS;
        }
        if ((encoder.clientCapabilitiesFlag & CapabilitiesFlag.CLIENT_CONNECT_ATTRS) != 0) {
            ByteBuf kv = allocateBuffer();
            foreach (string key, string value ; clientConnectionAttributes) {
                BufferUtils.writeLengthEncodedString(kv, key, StandardCharsets.UTF_8);
                BufferUtils.writeLengthEncodedString(kv, value, StandardCharsets.UTF_8);
            }
            BufferUtils.writeLengthEncodedInteger(packet, kv.readableBytes());
            packet.writeBytes(kv);
        }

        // set payload length
        int lenOfPayload = packet.writerIndex() - packetStartIdx - 4;
        packet.setMediumLE(packetStartIdx, lenOfPayload);

        sendPacket(packet, lenOfPayload);
    }

    private void sendAuthSwitchResponse(byte[] responseData) {
        int payloadLength = cast(int)responseData.length;
        ByteBuf packet = allocateBuffer(payloadLength + 4);
        // encode packet header
        packet.writeMediumLE(payloadLength);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeBytes(responseData);

        sendNonSplitPacket(packet);
    }
}
