module hunt.database.mysql.impl.codec;

import io.netty.buffer.ByteBuf;
import hunt.database.mysql.impl.command.DebugCommand;

class DebugCommandCodec : CommandCodec!(Void, DebugCommand) {
  private static final int PAYLOAD_LENGTH = 1;

  DebugCommandCodec(DebugCommand cmd) {
    super(cmd);
  }

  override
  void encode(MySQLEncoder encoder) {
    super.encode(encoder);
    sendDebugCommand();
  }

  override
  void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
    handleOkPacketOrErrorPacketPayload(payload);
  }

  private void sendDebugCommand() {
    ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
    // encode packet header
    packet.writeMediumLE(PAYLOAD_LENGTH);
    packet.writeByte(sequenceId);

    // encode packet payload
    packet.writeByte(CommandType.COM_DEBUG);

    sendPacket(packet, 1);
  }
}
