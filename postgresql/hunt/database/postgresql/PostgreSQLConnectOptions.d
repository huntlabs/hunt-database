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

import hunt.database.postgresql.SslMode;
import hunt.database.postgresql.impl.PgConnectionUriParser;
// import io.vertx.codegen.annotations.DataObject;
// import io.vertx.core.buffer.Buffer;
// import io.vertx.core.json.JsonObject;
// import io.vertx.core.net.*;
import hunt.database.base.SqlConnectOptions;

import hunt.collections.Collections;
import hunt.collections.HashMap;
import hunt.collections.Map;
import hunt.collections.Set;
import hunt.Exceptions;

import core.time;
import std.concurrency : initOnce;
import std.string;


// import static java.lang.Integer.parseInt;
// import static java.lang.System.getenv;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 * @author Billy Yuan <billy112487983@gmail.com>
 */
class PgConnectOptions : SqlConnectOptions {

    /**
     * Provide a {@link PgConnectOptions} configured from a connection URI.
     *
     * @param connectionUri the connection URI to configure from
     * @return a {@link PgConnectOptions} parsed from the connection URI
     * @throws IllegalArgumentException when the {@code connectionUri} is in an invalid format
     */
    // static PgConnectOptions fromUri(string connectionUri) {
    //     JsonObject parsedConfiguration = PgConnectionUriParser.parse(connectionUri);
    //     return new PgConnectOptions(parsedConfiguration);
    // }

    /**
     * Provide a {@link PgConnectOptions} configured with environment variables, if the environment variable
     * is not set, then a default value will take precedence over this.
     */
    // static PgConnectOptions fromEnv() {
    //     PgConnectOptions pgConnectOptions = new PgConnectOptions();

    //     if (getenv("PGHOSTADDR") is null) {
    //         if (getenv("PGHOST") !is null) {
    //             pgConnectOptions.setHost(getenv("PGHOST"));
    //         }
    //     } else {
    //         pgConnectOptions.setHost(getenv("PGHOSTADDR"));
    //     }

    //     if (getenv("PGPORT") !is null) {
    //         try {
    //             pgConnectOptions.setPort(parseInt(getenv("PGPORT")));
    //         } catch (NumberFormatException e) {
    //             // port will be set to default
    //         }
    //     }

    //     if (getenv("PGDATABASE") !is null) {
    //         pgConnectOptions.setDatabase(getenv("PGDATABASE"));
    //     }
    //     if (getenv("PGUSER") !is null) {
    //         pgConnectOptions.setUser(getenv("PGUSER"));
    //     }
    //     if (getenv("PGPASSWORD") !is null) {
    //         pgConnectOptions.setPassword(getenv("PGPASSWORD"));
    //     }
    //     if (getenv("PGSSLMODE") !is null) {
    //         pgConnectOptions.setSslMode(SslMode.of(getenv("PGSSLMODE")));
    //     }
    //     return pgConnectOptions;
    // }

    enum string DEFAULT_HOST = "localhost";
    static int DEFAULT_PORT = 5432;
    enum string DEFAULT_DATABASE = "db";
    enum string DEFAULT_USER = "user";
    enum string DEFAULT_PASSWORD = "pass";
    enum int DEFAULT_PIPELINING_LIMIT = 256;
    enum SslMode DEFAULT_SSLMODE = SslMode.DISABLE;
    static Map!(string, string) DEFAULT_PROPERTIES() {
        __gshared Map!(string, string) inst;
        return initOnce!inst(createDefaultProperties());
    }

    private static Map!(string, string) createDefaultProperties() {
        Map!(string, string) defaultProperties = new HashMap!(string, string)();
        defaultProperties.put("application_name", "vertx-pg-client");
        defaultProperties.put("client_encoding", "utf8");
        defaultProperties.put("DateStyle", "ISO");
        defaultProperties.put("intervalStyle", "postgres");
        defaultProperties.put("extra_float_digits", "2");
        return defaultProperties;
    }

    private int pipeliningLimit;
    private SslMode sslMode;

    this() {
        super();
    }

    // this(JsonObject json) {
    //     super(json);
    //     PgConnectOptionsConverter.fromJson(json, this);
    // }

    this(PgConnectOptions other) {
        super(other);
        pipeliningLimit = other.pipeliningLimit;
        sslMode = other.sslMode;
    }

    override
    PgConnectOptions setHost(string host) {
        return cast(PgConnectOptions) super.setHost(host);
    }

    override
    PgConnectOptions setPort(int port) {
        return cast(PgConnectOptions) super.setPort(port);
    }

    override
    PgConnectOptions setUser(string user) {
        return cast(PgConnectOptions) super.setUser(user);
    }

    override
    PgConnectOptions setPassword(string password) {
        return cast(PgConnectOptions) super.setPassword(password);
    }

    override
    PgConnectOptions setDatabase(string database) {
        return cast(PgConnectOptions) super.setDatabase(database);
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

    PgConnectOptions setCachePreparedStatements(bool cachePreparedStatements) {
        return cast(PgConnectOptions) super.setCachePreparedStatements(cachePreparedStatements);
    }

    override
    PgConnectOptions setPreparedStatementCacheMaxSize(int preparedStatementCacheMaxSize) {
        return cast(PgConnectOptions) super.setPreparedStatementCacheMaxSize(preparedStatementCacheMaxSize);
    }

    override
    PgConnectOptions setPreparedStatementCacheSqlLimit(int preparedStatementCacheSqlLimit) {
        return cast(PgConnectOptions) super.setPreparedStatementCacheSqlLimit(preparedStatementCacheSqlLimit);
    }

    override
    PgConnectOptions setProperties(Map!(string, string) properties) {
        return cast(PgConnectOptions) super.setProperties(properties);
    }

    override
    PgConnectOptions addProperty(string key, string value) {
        return cast(PgConnectOptions) super.addProperty(key, value);
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
        return cast(PgConnectOptions) super.setSendBufferSize(sendBufferSize);
    }

    override
    PgConnectOptions setReceiveBufferSize(int receiveBufferSize) {
        return cast(PgConnectOptions) super.setReceiveBufferSize(receiveBufferSize);
    }

    override
    PgConnectOptions setReuseAddress(bool reuseAddress) {
        return cast(PgConnectOptions) super.setReuseAddress(reuseAddress);
    }

    override
    PgConnectOptions setTrafficClass(int trafficClass) {
        return cast(PgConnectOptions) super.setTrafficClass(trafficClass);
    }

    override
    PgConnectOptions setTcpNoDelay(bool tcpNoDelay) {
        return cast(PgConnectOptions) super.setTcpNoDelay(tcpNoDelay);
    }

    override
    PgConnectOptions setTcpKeepAlive(bool tcpKeepAlive) {
        return cast(PgConnectOptions) super.setTcpKeepAlive(tcpKeepAlive);
    }

    override
    PgConnectOptions setSoLinger(int soLinger) {
        return cast(PgConnectOptions) super.setSoLinger(soLinger);
    }

    override
    PgConnectOptions setUsePooledBuffers(bool usePooledBuffers) {
        return cast(PgConnectOptions) super.setUsePooledBuffers(usePooledBuffers);
    }

    override
    PgConnectOptions setIdleTimeout(int idleTimeout) {
        return cast(PgConnectOptions) super.setIdleTimeout(idleTimeout);
    }

    override
    PgConnectOptions setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
        return cast(PgConnectOptions) super.setIdleTimeoutUnit(idleTimeoutUnit);
    }

    override
    PgConnectOptions setSsl(bool ssl) {
        if (ssl) {
            setSslMode(SslMode.VERIFY_CA);
        } else {
            setSslMode(SslMode.DISABLE);
        }
        return this;
    }

    // override
    // PgConnectOptions setKeyCertOptions(KeyCertOptions options) {
    //     return cast(PgConnectOptions) super.setKeyCertOptions(options);
    // }

    // override
    // PgConnectOptions setKeyStoreOptions(JksOptions options) {
    //     return cast(PgConnectOptions) super.setKeyStoreOptions(options);
    // }

    // override
    // PgConnectOptions setPfxKeyCertOptions(PfxOptions options) {
    //     return cast(PgConnectOptions) super.setPfxKeyCertOptions(options);
    // }

    // override
    // PgConnectOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //     return cast(PgConnectOptions) super.setPemKeyCertOptions(options);
    // }

    // override
    // PgConnectOptions setTrustOptions(TrustOptions options) {
    //     return cast(PgConnectOptions) super.setTrustOptions(options);
    // }

    // override
    // PgConnectOptions setTrustStoreOptions(JksOptions options) {
    //     return cast(PgConnectOptions) super.setTrustStoreOptions(options);
    // }

    // override
    // PgConnectOptions setPemTrustOptions(PemTrustOptions options) {
    //     return cast(PgConnectOptions) super.setPemTrustOptions(options);
    // }

    // override
    // PgConnectOptions setPfxTrustOptions(PfxOptions options) {
    //     return cast(PgConnectOptions) super.setPfxTrustOptions(options);
    // }

    // override
    // PgConnectOptions addEnabledCipherSuite(string suite) {
    //     return cast(PgConnectOptions) super.addEnabledCipherSuite(suite);
    // }

    // override
    // PgConnectOptions addEnabledSecureTransportProtocol(string protocol) {
    //     return cast(PgConnectOptions) super.addEnabledSecureTransportProtocol(protocol);
    // }

    // override
    // PgConnectOptions addCrlPath(string crlPath) {
    //     return cast(PgConnectOptions) super.addCrlPath(crlPath);
    // }

    // override
    // PgConnectOptions addCrlValue(Buffer crlValue) {
    //     return cast(PgConnectOptions) super.addCrlValue(crlValue);
    // }

    // override
    // PgConnectOptions setTrustAll(bool trustAll) {
    //     return cast(PgConnectOptions) super.setTrustAll(trustAll);
    // }

    override
    PgConnectOptions setConnectTimeout(int connectTimeout) {
        return cast(PgConnectOptions) super.setConnectTimeout(connectTimeout);
    }

    override
    PgConnectOptions setMetricsName(string metricsName) {
        return cast(PgConnectOptions) super.setMetricsName(metricsName);
    }

    override
    PgConnectOptions setReconnectAttempts(int attempts) {
        return cast(PgConnectOptions) super.setReconnectAttempts(attempts);
    }

    override
    PgConnectOptions setHostnameVerificationAlgorithm(string hostnameVerificationAlgorithm) {
        return cast(PgConnectOptions) super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
    }

    override
    PgConnectOptions setLogActivity(bool logEnabled) {
        return cast(PgConnectOptions) super.setLogActivity(logEnabled);
    }

    override
    PgConnectOptions setReconnectInterval(long interval) {
        return cast(PgConnectOptions) super.setReconnectInterval(interval);
    }

    override
    PgConnectOptions setProxyOptions(ProxyOptions proxyOptions) {
        return cast(PgConnectOptions) super.setProxyOptions(proxyOptions);
    }

    override
    PgConnectOptions setLocalAddress(string localAddress) {
        return cast(PgConnectOptions) super.setLocalAddress(localAddress);
    }

    override
    PgConnectOptions setUseAlpn(bool useAlpn) {
        return cast(PgConnectOptions) super.setUseAlpn(useAlpn);
    }

    // override
    // PgConnectOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     return cast(PgConnectOptions) super.setSslEngineOptions(sslEngineOptions);
    // }

    // override
    // PgConnectOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return cast(PgConnectOptions) super.setJdkSslEngineOptions(sslEngineOptions);
    // }

    override
    PgConnectOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
        return cast(PgConnectOptions) super.setOpenSslEngineOptions(sslEngineOptions);
    }

    override
    PgConnectOptions setReusePort(bool reusePort) {
        return cast(PgConnectOptions) super.setReusePort(reusePort);
    }

    override
    PgConnectOptions setTcpFastOpen(bool tcpFastOpen) {
        return cast(PgConnectOptions) super.setTcpFastOpen(tcpFastOpen);
    }

    override
    PgConnectOptions setTcpCork(bool tcpCork) {
        return cast(PgConnectOptions) super.setTcpCork(tcpCork);
    }

    override
    PgConnectOptions setTcpQuickAck(bool tcpQuickAck) {
        return cast(PgConnectOptions) super.setTcpQuickAck(tcpQuickAck);
    }

    override
    PgConnectOptions setEnabledSecureTransportProtocols(Set!(string) enabledSecureTransportProtocols) {
        return cast(PgConnectOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
    }

    override
    PgConnectOptions setSslHandshakeTimeout(long sslHandshakeTimeout) {
        return cast(PgConnectOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
    }

    override
    PgConnectOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
        return cast(PgConnectOptions) super.setSslHandshakeTimeoutUnit(sslHandshakeTimeoutUnit);
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
        this.setProperties(new HashMap!(string, string)(DEFAULT_PROPERTIES));
    }

    // override
    // JsonObject toJson() {
    //     JsonObject json = super.toJson();
    //     PgConnectOptionsConverter.toJson(this, json);
    //     return json;
    // }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        PgConnectOptions that = cast(PgConnectOptions) o;
        if(that is null) return false;

        if (pipeliningLimit != that.pipeliningLimit) return false;
        if (sslMode != that.sslMode) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        int result = super.toHash();
        result = 31 * result + pipeliningLimit;
        result = 31 * result + sslMode.toHash();
        return result;
    }

    bool isUsingDomainSocket() {
        return this.getHost().startsWith("/");
    }
}
