module hunt.database.mysql.impl.codec.InitDbCommandCodec;

import io.netty.buffer.ByteBuf;
import hunt.database.mysql.impl.command.InitDbCommand;

import java.nio.charset.StandardCharsets;

class InitDbCommandCodec : CommandCodec!(Void, InitDbCommand) {
  InitDbCommandCodec(InitDbCommand cmd) {
    super(cmd);
  }

  override
  void encode(MySQLEncoder encoder) {
    super.encode(encoder);
    sendInitDbCommand();
  }

  override
  void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
    handleOkPacketOrErrorPacketPayload(payload);
  }

  private void sendInitDbCommand() {
    ByteBuf packet = allocateBuffer();
    // encode packet header
    int packetStartIdx = packet.writerIndex();
    packet.writeMediumLE(0); // will set payload length later by calculation
    packet.writeByte(sequenceId);

    // encode packet payload
    packet.writeByte(CommandType.COM_INIT_DB);
    packet.writeCharSequence(cmd.schemaName(), StandardCharsets.UTF_8);

    // set payload length
    int lenOfPayload = packet.writerIndex() - packetStartIdx - 4;
    packet.setMediumLE(packetStartIdx, lenOfPayload);

    sendPacket(packet, lenOfPayload);
  }
}
