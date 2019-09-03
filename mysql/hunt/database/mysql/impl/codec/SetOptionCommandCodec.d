module hunt.database.mysql.impl.codec.SetOptionCommandCodec;

import hunt.database.mysql.impl.command.SetOptionCommand;

import hunt.net.buffer.ByteBuf;

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
        packet.writeShortLE(cmd.option().ordinal());

        sendNonSplitPacket(packet);
    }
}
