module hunt.database.driver.mysql.impl.codec.PingCommandCodec;

import hunt.database.driver.mysql.impl.codec.CommandCodec;
import hunt.database.driver.mysql.impl.codec.CommandType;
import hunt.database.driver.mysql.impl.codec.MySQLEncoder;

import hunt.database.driver.mysql.impl.command.PingCommand;
import hunt.database.base.impl.command.CommandResponse;

import hunt.net.buffer.ByteBuf;
import hunt.Object;

/**
 * 
 */
class PingCommandCodec : CommandCodec!(Void, PingCommand) {
    private enum int PAYLOAD_LENGTH = 1;

    this(PingCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendPingCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        // we don't care what the response payload is from the server
        if(completionHandler !is null) {
            completionHandler(succeededResponse(cast(ICommandResponse)null));
        }
    }

    private void sendPingCommand() {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_PING);

        sendNonSplitPacket(packet);
    }
}
