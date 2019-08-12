module hunt.database.mysql.impl.codec;

import io.netty.buffer.ByteBuf;
import hunt.database.mysql.impl.command.ResetConnectionCommand;

class ResetConnectionCommandCodec : CommandCodec!(Void, ResetConnectionCommand) {
  private static final int PAYLOAD_LENGTH = 1;

  ResetConnectionCommandCodec(ResetConnectionCommand cmd) {
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
