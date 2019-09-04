module hunt.database.mysql.impl.codec.ResetConnectionCommandCodec;

import hunt.database.mysql.impl.codec.CommandCodec;
import hunt.database.mysql.impl.codec.CommandType;
import hunt.database.mysql.impl.codec.MySQLEncoder;

import hunt.database.mysql.impl.command.ResetConnectionCommand;

import hunt.net.buffer.ByteBuf;
import hunt.Object;

class ResetConnectionCommandCodec : CommandCodec!(Void, ResetConnectionCommand) {
    private enum int PAYLOAD_LENGTH = 1;

    this(ResetConnectionCommand cmd) {
        super(cmd);
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        sendResetConnectionCommand();
    }

    override
    void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
        handleOkPacketOrErrorPacketPayload(payload);
    }

    private void sendResetConnectionCommand() {
        ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
        // encode packet header
        packet.writeMediumLE(PAYLOAD_LENGTH);
        packet.writeByte(sequenceId);

        // encode packet payload
        packet.writeByte(CommandType.COM_RESET_CONNECTION);

        sendNonSplitPacket(packet);
    }
}
