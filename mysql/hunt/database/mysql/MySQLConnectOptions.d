module hunt.database.mysql.MySQLConnectOptions;

import hunt.database.base.SqlConnectOptions;

import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.net.OpenSSLEngineOptions;
import hunt.net.ProxyOptions;
import hunt.net.util.HttpURI;
import hunt.Exceptions;

import core.time;

/**
 * Connect options for configuring {@link MySQLConnection} or {@link MySQLPool}.
 */
class MySQLConnectOptions : SqlConnectOptions {

    /**
     * Provide a {@link MySQLConnectOptions} configured from a connection URI.
     *
     * @param connectionUri the connection URI to configure from
     * @return a {@link MySQLConnectOptions} parsed from the connection URI
     * @throws IllegalArgumentException when the {@code connectionUri} is in an invalid format
     */
    // static MySQLConnectOptions fromUri(string connectionUri) {
    //     JsonObject parsedConfiguration = MySQLConnectionUriParser.parse(connectionUri);
    //     return new MySQLConnectOptions(parsedConfiguration);
    // }

    enum string DEFAULT_HOST = "localhost";
    enum int DEFAULT_PORT = 3306;
    enum string DEFAULT_USER = "root";
    enum string DEFAULT_PASSWORD = "";
    enum string DEFAULT_SCHEMA = "";
    enum string DEFAULT_COLLATION = "utf8mb4_general_ci";
    // enum Map!(string, string) DEFAULT_CONNECTION_ATTRIBUTES;
    enum string[string] DEFAULT_CONNECTION_ATTRIBUTES = ["_client_name" : "hunt-mysql-client",
        "_client_version" : "1.0.0"];

    // static {
    //     Map!(string, string) defaultAttributes = new HashMap<>();
    //     defaultAttributes.put("_client_name", "vertx-mysql-client");
    //     defaultAttributes.put("_client_version", "3.8.0");
    //     DEFAULT_CONNECTION_ATTRIBUTES = Collections.unmodifiableMap(defaultAttributes);
    // }

    private string collation;

    this() {
        super();
        this.collation = DEFAULT_COLLATION;
    }

    // this(JsonObject json) {
    //     super(json);
    //     this.collation = DEFAULT_COLLATION;
    //     MySQLConnectOptionsConverter.fromJson(json, this);
    // }

    this(MySQLConnectOptions other) {
        super(other);
        this.collation = other.collation;
    }

    /**
     * Get the collation for the connection.
     *
     * @return the MySQL collation
     */
    string getCollation() {
        return collation;
    }

    /**
     * Set the collation for the connection.
     *
     * @param collation the collation to set
     * @return a reference to this, so the API can be used fluently
     */
    MySQLConnectOptions setCollation(string collation) {
        this.collation = collation;
        return this;
    }

    override
    MySQLConnectOptions setHost(string host) {
        return cast(MySQLConnectOptions) super.setHost(host);
    }

    override
    MySQLConnectOptions setPort(int port) {
        return cast(MySQLConnectOptions) super.setPort(port);
    }

    override
    MySQLConnectOptions setUser(string user) {
        return cast(MySQLConnectOptions) super.setUser(user);
    }

    override
    MySQLConnectOptions setPassword(string password) {
        return cast(MySQLConnectOptions) super.setPassword(password);
    }

    override
    MySQLConnectOptions setDatabase(string database) {
        return cast(MySQLConnectOptions) super.setDatabase(database);
    }

    override
    MySQLConnectOptions setCachePreparedStatements(bool cachePreparedStatements) {
        return cast(MySQLConnectOptions) super.setCachePreparedStatements(cachePreparedStatements);
    }

    override
    MySQLConnectOptions setPreparedStatementCacheMaxSize(int preparedStatementCacheMaxSize) {
        return cast(MySQLConnectOptions) super.setPreparedStatementCacheMaxSize(preparedStatementCacheMaxSize);
    }

    override
    MySQLConnectOptions setPreparedStatementCacheSqlLimit(int preparedStatementCacheSqlLimit) {
        return cast(MySQLConnectOptions) super.setPreparedStatementCacheSqlLimit(preparedStatementCacheSqlLimit);
    }

    override
    MySQLConnectOptions setProperties(Map!(string, string) properties) {
        return cast(MySQLConnectOptions) super.setProperties(properties);
    }

    override
    MySQLConnectOptions addProperty(string key, string value) {
        return cast(MySQLConnectOptions) super.addProperty(key, value);
    }

    override
    MySQLConnectOptions setSendBufferSize(int sendBufferSize) {
        return cast(MySQLConnectOptions) super.setSendBufferSize(sendBufferSize);
    }

    override
    MySQLConnectOptions setReceiveBufferSize(int receiveBufferSize) {
        return cast(MySQLConnectOptions) super.setReceiveBufferSize(receiveBufferSize);
    }

    override
    MySQLConnectOptions setReuseAddress(bool reuseAddress) {
        return cast(MySQLConnectOptions) super.setReuseAddress(reuseAddress);
    }

    override
    MySQLConnectOptions setReusePort(bool reusePort) {
        return cast(MySQLConnectOptions) super.setReusePort(reusePort);
    }

    override
    MySQLConnectOptions setTrafficClass(int trafficClass) {
        return cast(MySQLConnectOptions) super.setTrafficClass(trafficClass);
    }

    override
    MySQLConnectOptions setTcpNoDelay(bool tcpNoDelay) {
        return cast(MySQLConnectOptions) super.setTcpNoDelay(tcpNoDelay);
    }

    override
    MySQLConnectOptions setTcpKeepAlive(bool tcpKeepAlive) {
        return cast(MySQLConnectOptions) super.setTcpKeepAlive(tcpKeepAlive);
    }

    override
    MySQLConnectOptions setSoLinger(int soLinger) {
        return cast(MySQLConnectOptions) super.setSoLinger(soLinger);
    }

    override
    MySQLConnectOptions setIdleTimeout(Duration idleTimeout) {
        return cast(MySQLConnectOptions) super.setIdleTimeout(idleTimeout);
    }

    // override
    // MySQLConnectOptions setKeyCertOptions(KeyCertOptions options) {
    //     return cast(MySQLConnectOptions) super.setKeyCertOptions(options);
    // }

    // override
    // MySQLConnectOptions setKeyStoreOptions(JksOptions options) {
    //     return cast(MySQLConnectOptions) super.setKeyStoreOptions(options);
    // }

    // override
    // MySQLConnectOptions setPfxKeyCertOptions(PfxOptions options) {
    //     return cast(MySQLConnectOptions) super.setPfxKeyCertOptions(options);
    // }

    // override
    // MySQLConnectOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //     return cast(MySQLConnectOptions) super.setPemKeyCertOptions(options);
    // }

    // override
    // MySQLConnectOptions setTrustOptions(TrustOptions options) {
    //     return cast(MySQLConnectOptions) super.setTrustOptions(options);
    // }

    // override
    // MySQLConnectOptions setTrustStoreOptions(JksOptions options) {
    //     return cast(MySQLConnectOptions) super.setTrustStoreOptions(options);
    // }

    // override
    // MySQLConnectOptions setPemTrustOptions(PemTrustOptions options) {
    //     return cast(MySQLConnectOptions) super.setPemTrustOptions(options);
    // }

    // override
    // MySQLConnectOptions setPfxTrustOptions(PfxOptions options) {
    //     return cast(MySQLConnectOptions) super.setPfxTrustOptions(options);
    // }

    // override
    // MySQLConnectOptions addEnabledCipherSuite(string suite) {
    //     return cast(MySQLConnectOptions) super.addEnabledCipherSuite(suite);
    // }

    // override
    // MySQLConnectOptions addEnabledSecureTransportProtocol(string protocol) {
    //     return cast(MySQLConnectOptions) super.addEnabledSecureTransportProtocol(protocol);
    // }

    // override
    // MySQLConnectOptions removeEnabledSecureTransportProtocol(string protocol) {
    //     return cast(MySQLConnectOptions) super.removeEnabledSecureTransportProtocol(protocol);
    // }

    override
    MySQLConnectOptions setUseAlpn(bool useAlpn) {
        return cast(MySQLConnectOptions) super.setUseAlpn(useAlpn);
    }

    // override
    // MySQLConnectOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     return cast(MySQLConnectOptions) super.setSslEngineOptions(sslEngineOptions);
    // }

    // override
    // MySQLConnectOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return cast(MySQLConnectOptions) super.setJdkSslEngineOptions(sslEngineOptions);
    // }

    override
    MySQLConnectOptions setTcpFastOpen(bool tcpFastOpen) {
        return cast(MySQLConnectOptions) super.setTcpFastOpen(tcpFastOpen);
    }

    override
    MySQLConnectOptions setTcpCork(bool tcpCork) {
        return cast(MySQLConnectOptions) super.setTcpCork(tcpCork);
    }

    override
    MySQLConnectOptions setTcpQuickAck(bool tcpQuickAck) {
        return cast(MySQLConnectOptions) super.setTcpQuickAck(tcpQuickAck);
    }

    // override
    // ClientOptionsBase setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    //     return super.setOpenSslEngineOptions(sslEngineOptions);
    // }

    // override
    // MySQLConnectOptions addCrlPath(string crlPath) {
    //     return cast(MySQLConnectOptions) super.addCrlPath(crlPath);
    // }

    // override
    // MySQLConnectOptions addCrlValue(Buffer crlValue) {
    //     return cast(MySQLConnectOptions) super.addCrlValue(crlValue);
    // }

    override
    MySQLConnectOptions setTrustAll(bool trustAll) {
        return cast(MySQLConnectOptions) super.setTrustAll(trustAll);
    }

    override
    MySQLConnectOptions setConnectTimeout(Duration connectTimeout) {
        return cast(MySQLConnectOptions) super.setConnectTimeout(connectTimeout);
    }

    override
    MySQLConnectOptions setMetricsName(string metricsName) {
        return cast(MySQLConnectOptions) super.setMetricsName(metricsName);
    }

    override
    MySQLConnectOptions setReconnectAttempts(int attempts) {
        return cast(MySQLConnectOptions) super.setReconnectAttempts(attempts);
    }

    override
    MySQLConnectOptions setReconnectInterval(Duration interval) {
        return cast(MySQLConnectOptions) super.setReconnectInterval(interval);
    }

    override
    MySQLConnectOptions setHostnameVerificationAlgorithm(string hostnameVerificationAlgorithm) {
        return cast(MySQLConnectOptions) super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
    }

    override
    MySQLConnectOptions setLogActivity(bool logEnabled) {
        return cast(MySQLConnectOptions) super.setLogActivity(logEnabled);
    }

    override
    MySQLConnectOptions setProxyOptions(ProxyOptions proxyOptions) {
        return cast(MySQLConnectOptions) super.setProxyOptions(proxyOptions);
    }

    override
    MySQLConnectOptions setLocalAddress(string localAddress) {
        return cast(MySQLConnectOptions) super.setLocalAddress(localAddress);
    }

    // override
    // MySQLConnectOptions setEnabledSecureTransportProtocols(Set!(string) enabledSecureTransportProtocols) {
    //     return cast(MySQLConnectOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
    // }

    override
    MySQLConnectOptions setSslHandshakeTimeout(Duration sslHandshakeTimeout) {
        return cast(MySQLConnectOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
    }

    /**
     * Initialize with the default options.
     */
    override protected void initialize() {
        this.setHost(DEFAULT_HOST);
        this.setPort(DEFAULT_PORT);
        this.setUser(DEFAULT_USER);
        this.setPassword(DEFAULT_PASSWORD);
        this.setDatabase(DEFAULT_SCHEMA);
        this.setProperties(new HashMap!(string, string)(DEFAULT_CONNECTION_ATTRIBUTES));
    }

    // override
    // JsonObject toJson() {
    //     JsonObject json = super.toJson();
    //     MySQLConnectOptionsConverter.toJson(this, json);
    //     return json;
    // }
}
