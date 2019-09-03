module hunt.database.mysql.impl.codec.ResetStatementCommandCodec;

import hunt.database.base.impl.command.CloseCursorCommand;

import hunt.net.buffer.ByteBuf;

class ResetStatementCommandCodec : CommandCodec!(Void, CloseCursorCommand) {
    private enum int PAYLOAD_LENGTH = 5;

    this(CloseCursorCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        MySQLPreparedStatement statement = cast(MySQLPreparedStatement) cmd.statement();

        statement.isCursorOpen = false;

        sendStatementResetCommand(statement);
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        handleOkPacketOrErrorPacketPayload(payload);
    }

    private void sendStatementResetCommand(MySQLPreparedStatement statement) {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_STMT_RESET);
        packet.writeIntLE(cast(int) statement.statementId);

        sendNonSplitPacket(packet);
    }
}
