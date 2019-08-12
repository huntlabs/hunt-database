module hunt.database.mysql.impl.codec.CloseConnectionCommandCodec;

import io.netty.buffer.ByteBuf;
import hunt.database.base.impl.command.CloseConnectionCommand;

class CloseConnectionCommandCodec : CommandCodec!(Void, CloseConnectionCommand) {
  private static final int PAYLOAD_LENGTH = 1;

  CloseConnectionCommandCodec(CloseConnectionCommand cmd) {
    super(cmd);
  }

  override
  void encode(MySQLEncoder encoder) {
    super.encode(encoder);
    sendQuitCommand();
  }

  override
  void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
    // connection will be terminated later
  }

  private void sendQuitCommand() {
    ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
    // encode packet header
    packet.writeMediumLE(PAYLOAD_LENGTH);
    packet.writeByte(sequenceId);

    // encode packet payload
    packet.writeByte(CommandType.COM_QUIT);

    sendNonSplitPacket(packet);
  }
}
