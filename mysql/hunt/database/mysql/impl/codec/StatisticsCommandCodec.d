module hunt.database.mysql.impl.codec.StatisticsCommandCodec;

import hunt.database.mysql.impl.command.StatisticsCommand;
import hunt.database.base.impl.command.CommandResponse;

import hunt.net.buffer.ByteBuf;


class StatisticsCommandCodec : CommandCodec!(String, StatisticsCommand) {
    private enum int PAYLOAD_LENGTH = 1;

    this(StatisticsCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendStatisticsCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        completionHandler.handle(CommandResponse.success(payload.toString(StandardCharsets.UTF_8)));
    }

    private void sendStatisticsCommand() {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_STATISTICS);

        sendNonSplitPacket(packet);
    }
}
