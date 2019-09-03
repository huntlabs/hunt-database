module hunt.database.mysql.impl.codec.CloseStatementCommandCodec;

import hunt.net.buffer.ByteBuf;
import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.CommandResponse;

class CloseStatementCommandCodec : CommandCodec!(Void, CloseStatementCommand) {
    private enum int PAYLOAD_LENGTH = 5;

    this(CloseStatementCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        MySQLPreparedStatement statement = cast(MySQLPreparedStatement) cmd.statement();
        sendCloseStatementCommand(statement);

        completionHandler.handle(CommandResponse.success(null));
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        // no statement response
    }

    private void sendCloseStatementCommand(MySQLPreparedStatement statement) {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_STMT_CLOSE);
        packet.writeIntLE(cast(int) statement.statementId);

        sendNonSplitPacket(packet);
    }
}
