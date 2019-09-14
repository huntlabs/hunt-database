module hunt.database.driver.mysql.impl.codec.SetOptionCommandCodec;

import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.CommandType;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;

import hunt.database.driver.mysql.impl.command.SetOptionCommand;

import hunt.net.buffer.ByteBuf;
import hunt.Object;

/**
 * 
 */
class SetOptionCommandCodec : CommandCodec!(Void, SetOptionCommand) {
    private enum int PAYLOAD_LENGTH = 3;

    this(SetOptionCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendSetOptionCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        handleOkPacketOrErrorPacketPayload(payload);
    }

    private void sendSetOptionCommand() {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_SET_OPTION);
        packet.writeShortLE(cast(int)cmd.option());

        sendNonSplitPacket(packet);
    }
}
