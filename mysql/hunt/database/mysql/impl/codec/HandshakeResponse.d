module hunt.database.mysql.impl.codec.HandshakeResponse;

import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Deprecated
//TODO we may drop this class later
final class HandshakeResponse {
  // https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_response.html

  private static final int maxPacketSize = 0xFFFFFF;

  private final String username;
  private final Charset charset;
  private final String password;
  private final String database;
  private final byte[] scramble;
  private final int clientCapabilitiesFlags;
  private final String authMethodName;
  private final Map!(String, String) clientConnectAttrs = new HashMap<>();

  HandshakeResponse(String username,
                           Charset charset,
                           String password,
                           String database,
                           byte[] scramble,
                           int clientCapabilitiesFlags,
                           String authMethodName,
                           Map!(String, String) clientConnectAttrs) {
    this.username = username;
    this.charset = charset;
    this.password = password;
    this.database = database;
    this.scramble = scramble;
    this.clientCapabilitiesFlags = clientCapabilitiesFlags;
    this.authMethodName = authMethodName;
    if (clientConnectAttrs !is null) {
      this.clientConnectAttrs.putAll(clientConnectAttrs);
    }
  }

  int getMaxPacketSize() {
    return maxPacketSize;
  }

  String getUsername() {
    return username;
  }

  Charset getCharset() {
    return charset;
  }

  String getPassword() {
    return password;
  }

  String getDatabase() {
    return database;
  }

  byte[] getScramble() {
    return scramble;
  }

  int getClientCapabilitiesFlags() {
    return clientCapabilitiesFlags;
  }

  String getAuthMethodName() {
    return authMethodName;
  }

  Map!(String, String) getClientConnectAttrs() {
    return clientConnectAttrs;
  }

  override
  String toString() {
    return "HandshakeResponse{" ~
      "username='" ~ username + '\'' +
      ", charset=" ~ charset +
      ", password='" ~ password + '\'' +
      ", database='" ~ database + '\'' +
      ", scramble=" ~ Arrays.toString(scramble) +
      ", clientCapabilitiesFlags=" ~ clientCapabilitiesFlags +
      ", authMethodName='" ~ authMethodName + '\'' +
      ", clientConnectAttrs=" ~ clientConnectAttrs +
      '}';
  }
}
