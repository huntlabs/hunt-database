/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.postgresql.PostgreSQLConnectOptions;

import hunt.database.postgresql.impl.PgConnectionUriParser;
import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.json.JsonObject;
import io.vertx.core.net.*;
import hunt.database.base.SqlConnectOptions;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import static java.lang.Integer.parseInt;
import static java.lang.System.getenv;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author Billy Yuan <billy112487983@gmail.com>
 */
@DataObject(generateConverter = true)
class PgConnectOptions : SqlConnectOptions {

  /**
   * Provide a {@link PgConnectOptions} configured from a connection URI.
   *
   * @param connectionUri the connection URI to configure from
   * @return a {@link PgConnectOptions} parsed from the connection URI
   * @throws IllegalArgumentException when the {@code connectionUri} is in an invalid format
   */
  static PgConnectOptions fromUri(String connectionUri) throws IllegalArgumentException {
    JsonObject parsedConfiguration = PgConnectionUriParser.parse(connectionUri);
    return new PgConnectOptions(parsedConfiguration);
  }

  /**
   * Provide a {@link PgConnectOptions} configured with environment variables, if the environment variable
   * is not set, then a default value will take precedence over this.
   */
  static PgConnectOptions fromEnv() {
    PgConnectOptions pgConnectOptions = new PgConnectOptions();

    if (getenv("PGHOSTADDR") == null) {
      if (getenv("PGHOST") != null) {
        pgConnectOptions.setHost(getenv("PGHOST"));
      }
    } else {
      pgConnectOptions.setHost(getenv("PGHOSTADDR"));
    }

    if (getenv("PGPORT") != null) {
      try {
        pgConnectOptions.setPort(parseInt(getenv("PGPORT")));
      } catch (NumberFormatException e) {
        // port will be set to default
      }
    }

    if (getenv("PGDATABASE") != null) {
      pgConnectOptions.setDatabase(getenv("PGDATABASE"));
    }
    if (getenv("PGUSER") != null) {
      pgConnectOptions.setUser(getenv("PGUSER"));
    }
    if (getenv("PGPASSWORD") != null) {
      pgConnectOptions.setPassword(getenv("PGPASSWORD"));
    }
    if (getenv("PGSSLMODE") != null) {
      pgConnectOptions.setSslMode(SslMode.of(getenv("PGSSLMODE")));
    }
    return pgConnectOptions;
  }

  static final String DEFAULT_HOST = "localhost";
  static int DEFAULT_PORT = 5432;
  static final String DEFAULT_DATABASE = "db";
  static final String DEFAULT_USER = "user";
  static final String DEFAULT_PASSWORD = "pass";
  static final int DEFAULT_PIPELINING_LIMIT = 256;
  static final SslMode DEFAULT_SSLMODE = SslMode.DISABLE;
  static final Map!(String, String) DEFAULT_PROPERTIES;

  static {
    Map!(String, String) defaultProperties = new HashMap<>();
    defaultProperties.put("application_name", "vertx-pg-client");
    defaultProperties.put("client_encoding", "utf8");
    defaultProperties.put("DateStyle", "ISO");
    defaultProperties.put("intervalStyle", "postgres");
    defaultProperties.put("extra_float_digits", "2");
    DEFAULT_PROPERTIES = Collections.unmodifiableMap(defaultProperties);
  }

  private int pipeliningLimit;
  private SslMode sslMode;

  PgConnectOptions() {
    super();
  }

  PgConnectOptions(JsonObject json) {
    super(json);
    PgConnectOptionsConverter.fromJson(json, this);
  }

  PgConnectOptions(PgConnectOptions other) {
    super(other);
    pipeliningLimit = other.pipeliningLimit;
    sslMode = other.sslMode;
  }

  override
  PgConnectOptions setHost(String host) {
    return (PgConnectOptions) super.setHost(host);
  }

  override
  PgConnectOptions setPort(int port) {
    return (PgConnectOptions) super.setPort(port);
  }

  override
  PgConnectOptions setUser(String user) {
    return (PgConnectOptions) super.setUser(user);
  }

  override
  PgConnectOptions setPassword(String password) {
    return (PgConnectOptions) super.setPassword(password);
  }

  override
  PgConnectOptions setDatabase(String database) {
    return (PgConnectOptions) super.setDatabase(database);
  }

  int getPipeliningLimit() {
    return pipeliningLimit;
  }

  PgConnectOptions setPipeliningLimit(int pipeliningLimit) {
    if (pipeliningLimit < 1) {
      throw new IllegalArgumentException();
    }
    this.pipeliningLimit = pipeliningLimit;
    return this;
  }

  PgConnectOptions setCachePreparedStatements(boolean cachePreparedStatements) {
    return (PgConnectOptions) super.setCachePreparedStatements(cachePreparedStatements);
  }

  override
  PgConnectOptions setPreparedStatementCacheMaxSize(int preparedStatementCacheMaxSize) {
    return (PgConnectOptions) super.setPreparedStatementCacheMaxSize(preparedStatementCacheMaxSize);
  }

  override
  PgConnectOptions setPreparedStatementCacheSqlLimit(int preparedStatementCacheSqlLimit) {
    return (PgConnectOptions) super.setPreparedStatementCacheSqlLimit(preparedStatementCacheSqlLimit);
  }

  override
  PgConnectOptions setProperties(Map!(String, String) properties) {
    return (PgConnectOptions) super.setProperties(properties);
  }

  override
  PgConnectOptions addProperty(String key, String value) {
    return (PgConnectOptions) super.addProperty(key, value);
  }

  /**
   * @return the value of current sslmode
   */
  SslMode getSslMode() {
    return sslMode;
  }

  /**
   * Set {@link SslMode} for the client, this option can be used to provide different levels of secure protection.
   *
   * @param sslmode the value of sslmode
   * @return a reference to this, so the API can be used fluently
   */
  PgConnectOptions setSslMode(SslMode sslmode) {
    this.sslMode = sslmode;
    return this;
  }

  override
  PgConnectOptions setSendBufferSize(int sendBufferSize) {
    return (PgConnectOptions)super.setSendBufferSize(sendBufferSize);
  }

  override
  PgConnectOptions setReceiveBufferSize(int receiveBufferSize) {
    return (PgConnectOptions)super.setReceiveBufferSize(receiveBufferSize);
  }

  override
  PgConnectOptions setReuseAddress(boolean reuseAddress) {
    return (PgConnectOptions)super.setReuseAddress(reuseAddress);
  }

  override
  PgConnectOptions setTrafficClass(int trafficClass) {
    return (PgConnectOptions)super.setTrafficClass(trafficClass);
  }

  override
  PgConnectOptions setTcpNoDelay(boolean tcpNoDelay) {
    return (PgConnectOptions)super.setTcpNoDelay(tcpNoDelay);
  }

  override
  PgConnectOptions setTcpKeepAlive(boolean tcpKeepAlive) {
    return (PgConnectOptions)super.setTcpKeepAlive(tcpKeepAlive);
  }

  override
  PgConnectOptions setSoLinger(int soLinger) {
    return (PgConnectOptions)super.setSoLinger(soLinger);
  }

  override
  PgConnectOptions setUsePooledBuffers(boolean usePooledBuffers) {
    return (PgConnectOptions)super.setUsePooledBuffers(usePooledBuffers);
  }

  override
  PgConnectOptions setIdleTimeout(int idleTimeout) {
    return (PgConnectOptions)super.setIdleTimeout(idleTimeout);
  }

  override
  PgConnectOptions setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
    return (PgConnectOptions) super.setIdleTimeoutUnit(idleTimeoutUnit);
  }

  override
  PgConnectOptions setSsl(boolean ssl) {
    if (ssl) {
      setSslMode(SslMode.VERIFY_CA);
    } else {
      setSslMode(SslMode.DISABLE);
    }
    return this;
  }

  override
  PgConnectOptions setKeyCertOptions(KeyCertOptions options) {
    return (PgConnectOptions)super.setKeyCertOptions(options);
  }

  override
  PgConnectOptions setKeyStoreOptions(JksOptions options) {
    return (PgConnectOptions)super.setKeyStoreOptions(options);
  }

  override
  PgConnectOptions setPfxKeyCertOptions(PfxOptions options) {
    return (PgConnectOptions)super.setPfxKeyCertOptions(options);
  }

  override
  PgConnectOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    return (PgConnectOptions)super.setPemKeyCertOptions(options);
  }

  override
  PgConnectOptions setTrustOptions(TrustOptions options) {
    return (PgConnectOptions)super.setTrustOptions(options);
  }

  override
  PgConnectOptions setTrustStoreOptions(JksOptions options) {
    return (PgConnectOptions)super.setTrustStoreOptions(options);
  }

  override
  PgConnectOptions setPemTrustOptions(PemTrustOptions options) {
    return (PgConnectOptions)super.setPemTrustOptions(options);
  }

  override
  PgConnectOptions setPfxTrustOptions(PfxOptions options) {
    return (PgConnectOptions)super.setPfxTrustOptions(options);
  }

  override
  PgConnectOptions addEnabledCipherSuite(String suite) {
    return (PgConnectOptions)super.addEnabledCipherSuite(suite);
  }

  override
  PgConnectOptions addEnabledSecureTransportProtocol(String protocol) {
    return (PgConnectOptions)super.addEnabledSecureTransportProtocol(protocol);
  }

  override
  PgConnectOptions addCrlPath(String crlPath) throws NullPointerException {
    return (PgConnectOptions)super.addCrlPath(crlPath);
  }

  override
  PgConnectOptions addCrlValue(Buffer crlValue) throws NullPointerException {
    return (PgConnectOptions)super.addCrlValue(crlValue);
  }

  override
  PgConnectOptions setTrustAll(boolean trustAll) {
    return (PgConnectOptions)super.setTrustAll(trustAll);
  }

  override
  PgConnectOptions setConnectTimeout(int connectTimeout) {
    return (PgConnectOptions)super.setConnectTimeout(connectTimeout);
  }

  override
  PgConnectOptions setMetricsName(String metricsName) {
    return (PgConnectOptions)super.setMetricsName(metricsName);
  }

  override
  PgConnectOptions setReconnectAttempts(int attempts) {
    return (PgConnectOptions)super.setReconnectAttempts(attempts);
  }

  override
  PgConnectOptions setHostnameVerificationAlgorithm(String hostnameVerificationAlgorithm) {
    return (PgConnectOptions)super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
  }

  override
  PgConnectOptions setLogActivity(boolean logEnabled) {
    return (PgConnectOptions)super.setLogActivity(logEnabled);
  }

  override
  PgConnectOptions setReconnectInterval(long interval) {
    return (PgConnectOptions)super.setReconnectInterval(interval);
  }

  override
  PgConnectOptions setProxyOptions(ProxyOptions proxyOptions) {
    return (PgConnectOptions)super.setProxyOptions(proxyOptions);
  }

  override
  PgConnectOptions setLocalAddress(String localAddress) {
    return (PgConnectOptions)super.setLocalAddress(localAddress);
  }

  override
  PgConnectOptions setUseAlpn(boolean useAlpn) {
    return (PgConnectOptions)super.setUseAlpn(useAlpn);
  }

  override
  PgConnectOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    return (PgConnectOptions)super.setSslEngineOptions(sslEngineOptions);
  }

  override
  PgConnectOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    return (PgConnectOptions)super.setJdkSslEngineOptions(sslEngineOptions);
  }

  override
  PgConnectOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    return (PgConnectOptions)super.setOpenSslEngineOptions(sslEngineOptions);
  }

  override
  PgConnectOptions setReusePort(boolean reusePort) {
    return (PgConnectOptions) super.setReusePort(reusePort);
  }

  override
  PgConnectOptions setTcpFastOpen(boolean tcpFastOpen) {
    return (PgConnectOptions) super.setTcpFastOpen(tcpFastOpen);
  }

  override
  PgConnectOptions setTcpCork(boolean tcpCork) {
    return (PgConnectOptions) super.setTcpCork(tcpCork);
  }

  override
  PgConnectOptions setTcpQuickAck(boolean tcpQuickAck) {
    return (PgConnectOptions) super.setTcpQuickAck(tcpQuickAck);
  }

  override
  PgConnectOptions setEnabledSecureTransportProtocols(Set!(String) enabledSecureTransportProtocols) {
    return (PgConnectOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
  }

  override
  PgConnectOptions setSslHandshakeTimeout(long sslHandshakeTimeout) {
    return (PgConnectOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
  }

  override
  PgConnectOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
    return (PgConnectOptions) super.setSslHandshakeTimeoutUnit(sslHandshakeTimeoutUnit);
  }

  /**
   * Initialize with the default options.
   */
  protected void init() {
    this.setHost(DEFAULT_HOST);
    this.setPort(DEFAULT_PORT);
    this.setUser(DEFAULT_USER);
    this.setPassword(DEFAULT_PASSWORD);
    this.setDatabase(DEFAULT_DATABASE);
    pipeliningLimit = DEFAULT_PIPELINING_LIMIT;
    sslMode = DEFAULT_SSLMODE;
    this.setProperties(new HashMap<>(DEFAULT_PROPERTIES));
  }

  override
  JsonObject toJson() {
    JsonObject json = super.toJson();
    PgConnectOptionsConverter.toJson(this, json);
    return json;
  }

  override
  bool opEquals(Object o) {
    if (this == o) return true;
    if (!(o instanceof PgConnectOptions)) return false;
    if (!super == o) return false;

    PgConnectOptions that = (PgConnectOptions) o;

    if (pipeliningLimit != that.pipeliningLimit) return false;
    if (sslMode != that.sslMode) return false;

    return true;
  }

  override
  size_t toHash() @trusted nothrow {
    int result = super.hashCode();
    result = 31 * result + pipeliningLimit;
    result = 31 * result + sslMode.hashCode();
    return result;
  }

  boolean isUsingDomainSocket() {
    return this.getHost().startsWith("/");
  }
}
