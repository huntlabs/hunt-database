module hunt.database.mysql;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.json.JsonObject;
import io.vertx.core.net.ClientOptionsBase;
import io.vertx.core.net.JdkSSLEngineOptions;
import io.vertx.core.net.JksOptions;
import io.vertx.core.net.KeyCertOptions;
import io.vertx.core.net.OpenSSLEngineOptions;
import io.vertx.core.net.PemKeyCertOptions;
import io.vertx.core.net.PemTrustOptions;
import io.vertx.core.net.PfxOptions;
import io.vertx.core.net.ProxyOptions;
import io.vertx.core.net.SSLEngineOptions;
import io.vertx.core.net.TrustOptions;
import hunt.database.mysql.impl.MySQLConnectionUriParser;
import hunt.database.base.SqlConnectOptions;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * Connect options for configuring {@link MySQLConnection} or {@link MySQLPool}.
 */
@DataObject(generateConverter = true)
class MySQLConnectOptions : SqlConnectOptions {

  /**
   * Provide a {@link MySQLConnectOptions} configured from a connection URI.
   *
   * @param connectionUri the connection URI to configure from
   * @return a {@link MySQLConnectOptions} parsed from the connection URI
   * @throws IllegalArgumentException when the {@code connectionUri} is in an invalid format
   */
  static MySQLConnectOptions fromUri(String connectionUri) throws IllegalArgumentException {
    JsonObject parsedConfiguration = MySQLConnectionUriParser.parse(connectionUri);
    return new MySQLConnectOptions(parsedConfiguration);
  }

  static final String DEFAULT_HOST = "localhost";
  static final int DEFAULT_PORT = 3306;
  static final String DEFAULT_USER = "root";
  static final String DEFAULT_PASSWORD = "";
  static final String DEFAULT_SCHEMA = "";
  static final String DEFAULT_COLLATION = "utf8mb4_general_ci";
  static final Map!(String, String) DEFAULT_CONNECTION_ATTRIBUTES;

  static {
    Map!(String, String) defaultAttributes = new HashMap<>();
    defaultAttributes.put("_client_name", "vertx-mysql-client");
    defaultAttributes.put("_client_version", "3.8.0");
    DEFAULT_CONNECTION_ATTRIBUTES = Collections.unmodifiableMap(defaultAttributes);
  }

  private String collation;

  MySQLConnectOptions() {
    super();
    this.collation = DEFAULT_COLLATION;
  }

  MySQLConnectOptions(JsonObject json) {
    super(json);
    this.collation = DEFAULT_COLLATION;
    MySQLConnectOptionsConverter.fromJson(json, this);
  }

  MySQLConnectOptions(MySQLConnectOptions other) {
    super(other);
    this.collation = other.collation;
  }

  /**
   * Get the collation for the connection.
   *
   * @return the MySQL collation
   */
  String getCollation() {
    return collation;
  }

  /**
   * Set the collation for the connection.
   *
   * @param collation the collation to set
   * @return a reference to this, so the API can be used fluently
   */
  MySQLConnectOptions setCollation(String collation) {
    this.collation = collation;
    return this;
  }

  override
  MySQLConnectOptions setHost(String host) {
    return (MySQLConnectOptions) super.setHost(host);
  }

  override
  MySQLConnectOptions setPort(int port) {
    return (MySQLConnectOptions) super.setPort(port);
  }

  override
  MySQLConnectOptions setUser(String user) {
    return (MySQLConnectOptions) super.setUser(user);
  }

  override
  MySQLConnectOptions setPassword(String password) {
    return (MySQLConnectOptions) super.setPassword(password);
  }

  override
  MySQLConnectOptions setDatabase(String database) {
    return (MySQLConnectOptions) super.setDatabase(database);
  }

  override
  MySQLConnectOptions setCachePreparedStatements(boolean cachePreparedStatements) {
    return (MySQLConnectOptions) super.setCachePreparedStatements(cachePreparedStatements);
  }

  override
  MySQLConnectOptions setPreparedStatementCacheMaxSize(int preparedStatementCacheMaxSize) {
    return (MySQLConnectOptions) super.setPreparedStatementCacheMaxSize(preparedStatementCacheMaxSize);
  }

  override
  MySQLConnectOptions setPreparedStatementCacheSqlLimit(int preparedStatementCacheSqlLimit) {
    return (MySQLConnectOptions) super.setPreparedStatementCacheSqlLimit(preparedStatementCacheSqlLimit);
  }

  override
  MySQLConnectOptions setProperties(Map!(String, String) properties) {
    return (MySQLConnectOptions) super.setProperties(properties);
  }

  override
  MySQLConnectOptions addProperty(String key, String value) {
    return (MySQLConnectOptions) super.addProperty(key, value);
  }

  override
  MySQLConnectOptions setSendBufferSize(int sendBufferSize) {
    return (MySQLConnectOptions) super.setSendBufferSize(sendBufferSize);
  }

  override
  MySQLConnectOptions setReceiveBufferSize(int receiveBufferSize) {
    return (MySQLConnectOptions) super.setReceiveBufferSize(receiveBufferSize);
  }

  override
  MySQLConnectOptions setReuseAddress(boolean reuseAddress) {
    return (MySQLConnectOptions) super.setReuseAddress(reuseAddress);
  }

  override
  MySQLConnectOptions setReusePort(boolean reusePort) {
    return (MySQLConnectOptions) super.setReusePort(reusePort);
  }

  override
  MySQLConnectOptions setTrafficClass(int trafficClass) {
    return (MySQLConnectOptions) super.setTrafficClass(trafficClass);
  }

  override
  MySQLConnectOptions setTcpNoDelay(boolean tcpNoDelay) {
    return (MySQLConnectOptions) super.setTcpNoDelay(tcpNoDelay);
  }

  override
  MySQLConnectOptions setTcpKeepAlive(boolean tcpKeepAlive) {
    return (MySQLConnectOptions) super.setTcpKeepAlive(tcpKeepAlive);
  }

  override
  MySQLConnectOptions setSoLinger(int soLinger) {
    return (MySQLConnectOptions) super.setSoLinger(soLinger);
  }

  override
  MySQLConnectOptions setUsePooledBuffers(boolean usePooledBuffers) {
    return (MySQLConnectOptions) super.setUsePooledBuffers(usePooledBuffers);
  }

  override
  MySQLConnectOptions setIdleTimeout(int idleTimeout) {
    return (MySQLConnectOptions) super.setIdleTimeout(idleTimeout);
  }

  override
  MySQLConnectOptions setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
    return (MySQLConnectOptions) super.setIdleTimeoutUnit(idleTimeoutUnit);
  }

  override
  MySQLConnectOptions setKeyCertOptions(KeyCertOptions options) {
    return (MySQLConnectOptions) super.setKeyCertOptions(options);
  }

  override
  MySQLConnectOptions setKeyStoreOptions(JksOptions options) {
    return (MySQLConnectOptions) super.setKeyStoreOptions(options);
  }

  override
  MySQLConnectOptions setPfxKeyCertOptions(PfxOptions options) {
    return (MySQLConnectOptions) super.setPfxKeyCertOptions(options);
  }

  override
  MySQLConnectOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    return (MySQLConnectOptions) super.setPemKeyCertOptions(options);
  }

  override
  MySQLConnectOptions setTrustOptions(TrustOptions options) {
    return (MySQLConnectOptions) super.setTrustOptions(options);
  }

  override
  MySQLConnectOptions setTrustStoreOptions(JksOptions options) {
    return (MySQLConnectOptions) super.setTrustStoreOptions(options);
  }

  override
  MySQLConnectOptions setPemTrustOptions(PemTrustOptions options) {
    return (MySQLConnectOptions) super.setPemTrustOptions(options);
  }

  override
  MySQLConnectOptions setPfxTrustOptions(PfxOptions options) {
    return (MySQLConnectOptions) super.setPfxTrustOptions(options);
  }

  override
  MySQLConnectOptions addEnabledCipherSuite(String suite) {
    return (MySQLConnectOptions) super.addEnabledCipherSuite(suite);
  }

  override
  MySQLConnectOptions addEnabledSecureTransportProtocol(String protocol) {
    return (MySQLConnectOptions) super.addEnabledSecureTransportProtocol(protocol);
  }

  override
  MySQLConnectOptions removeEnabledSecureTransportProtocol(String protocol) {
    return (MySQLConnectOptions) super.removeEnabledSecureTransportProtocol(protocol);
  }

  override
  MySQLConnectOptions setUseAlpn(boolean useAlpn) {
    return (MySQLConnectOptions) super.setUseAlpn(useAlpn);
  }

  override
  MySQLConnectOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    return (MySQLConnectOptions) super.setSslEngineOptions(sslEngineOptions);
  }

  override
  MySQLConnectOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    return (MySQLConnectOptions) super.setJdkSslEngineOptions(sslEngineOptions);
  }

  override
  MySQLConnectOptions setTcpFastOpen(boolean tcpFastOpen) {
    return (MySQLConnectOptions) super.setTcpFastOpen(tcpFastOpen);
  }

  override
  MySQLConnectOptions setTcpCork(boolean tcpCork) {
    return (MySQLConnectOptions) super.setTcpCork(tcpCork);
  }

  override
  MySQLConnectOptions setTcpQuickAck(boolean tcpQuickAck) {
    return (MySQLConnectOptions) super.setTcpQuickAck(tcpQuickAck);
  }

  override
  ClientOptionsBase setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    return super.setOpenSslEngineOptions(sslEngineOptions);
  }

  override
  MySQLConnectOptions addCrlPath(String crlPath) throws NullPointerException {
    return (MySQLConnectOptions) super.addCrlPath(crlPath);
  }

  override
  MySQLConnectOptions addCrlValue(Buffer crlValue) throws NullPointerException {
    return (MySQLConnectOptions) super.addCrlValue(crlValue);
  }

  override
  MySQLConnectOptions setTrustAll(boolean trustAll) {
    return (MySQLConnectOptions) super.setTrustAll(trustAll);
  }

  override
  MySQLConnectOptions setConnectTimeout(int connectTimeout) {
    return (MySQLConnectOptions) super.setConnectTimeout(connectTimeout);
  }

  override
  MySQLConnectOptions setMetricsName(String metricsName) {
    return (MySQLConnectOptions) super.setMetricsName(metricsName);
  }

  override
  MySQLConnectOptions setReconnectAttempts(int attempts) {
    return (MySQLConnectOptions) super.setReconnectAttempts(attempts);
  }

  override
  MySQLConnectOptions setReconnectInterval(long interval) {
    return (MySQLConnectOptions) super.setReconnectInterval(interval);
  }

  override
  MySQLConnectOptions setHostnameVerificationAlgorithm(String hostnameVerificationAlgorithm) {
    return (MySQLConnectOptions) super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
  }

  override
  MySQLConnectOptions setLogActivity(boolean logEnabled) {
    return (MySQLConnectOptions) super.setLogActivity(logEnabled);
  }

  override
  MySQLConnectOptions setProxyOptions(ProxyOptions proxyOptions) {
    return (MySQLConnectOptions) super.setProxyOptions(proxyOptions);
  }

  override
  MySQLConnectOptions setLocalAddress(String localAddress) {
    return (MySQLConnectOptions) super.setLocalAddress(localAddress);
  }

  override
  MySQLConnectOptions setEnabledSecureTransportProtocols(Set!(String) enabledSecureTransportProtocols) {
    return (MySQLConnectOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
  }

  override
  MySQLConnectOptions setSslHandshakeTimeout(long sslHandshakeTimeout) {
    return (MySQLConnectOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
  }

  override
  MySQLConnectOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
    return (MySQLConnectOptions) super.setSslHandshakeTimeoutUnit(sslHandshakeTimeoutUnit);
  }

  /**
   * Initialize with the default options.
   */
  protected void init() {
    this.setHost(DEFAULT_HOST);
    this.setPort(DEFAULT_PORT);
    this.setUser(DEFAULT_USER);
    this.setPassword(DEFAULT_PASSWORD);
    this.setDatabase(DEFAULT_SCHEMA);
    this.setProperties(new HashMap<>(DEFAULT_CONNECTION_ATTRIBUTES));
  }

  override
  JsonObject toJson() {
    JsonObject json = super.toJson();
    MySQLConnectOptionsConverter.toJson(this, json);
    return json;
  }
}
