module hunt.database.mysql.impl.codec.InitialHandshakePacket;

import java.util.Arrays;

@Deprecated
//TODO we may drop this class later
final class InitialHandshakePacket {
  /*
    https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_v10.html
   */

  private final byte protocolVersion = 10;
  private final String serverVersion;
  private final long connectionId;
  private final int serverCapabilitiesFlags;
  private final short characterSet;
  private final int serverStatusFlags;
  private final byte[] scramble;
  private final String authMethodName;


  InitialHandshakePacket(String serverVersion,
                                long connectionId,
                                int serverCapabilitiesFlags,
                                short characterSet,
                                int serverStatusFlags,
                                byte[] scramble,
                                String authMethodName) {
    this.serverVersion = serverVersion;
    this.connectionId = connectionId;
    this.serverCapabilitiesFlags = serverCapabilitiesFlags;
    this.characterSet = characterSet;
    this.serverStatusFlags = serverStatusFlags;
    this.scramble = scramble;
    this.authMethodName = authMethodName;
  }

  byte getProtocolVersion() {
    return protocolVersion;
  }

  String getServerVersion() {
    return serverVersion;
  }

  long getConnectionId() {
    return connectionId;
  }

  int getServerCapabilitiesFlags() {
    return serverCapabilitiesFlags;
  }

  short getCharacterSet() {
    return characterSet;
  }

  int getServerStatusFlags() {
    return serverStatusFlags;
  }

  byte[] getScramble() {
    return scramble;
  }

  String getAuthMethodName() {
    return authMethodName;
  }

  override
  string toString() {
    return "InitialHandshakePacket{" ~
      "protocolVersion=" ~ protocolVersion +
      ", serverVersion='" ~ serverVersion + '\'' +
      ", connectionId=" ~ connectionId +
      ", serverCapabilitiesFlags=" ~ serverCapabilitiesFlags +
      ", characterSet=" ~ characterSet +
      ", serverStatusFlags=" ~ serverStatusFlags +
      ", scramble=" ~ Arrays.toString(scramble) +
      ", authMethodName='" ~ authMethodName + '\'' +
      '}';
  }
}
