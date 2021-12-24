module hunt.database.base.SqlConnectOptions;

import hunt.net.NetClientOptions;
import hunt.net.util.HttpURI;

import hunt.collection;
import hunt.Exceptions;
import hunt.logging;

import std.array;

/**
 * Connect options for configuring {@link SqlConnection} or {@link Pool}.
 */
abstract class SqlConnectOptions : NetClientOptions {
    enum bool DEFAULT_CACHE_PREPARED_STATEMENTS = false;
    enum int DEFAULT_PREPARED_STATEMENT_CACHE_MAX_SIZE = 256;
    enum int DEFAULT_PREPARED_STATEMENT_CACHE_SQL_LIMIT = 2048;

    private string host;
    private int port;
    private string user;
    private string password;
    private string database;
    private bool cachePreparedStatements = DEFAULT_CACHE_PREPARED_STATEMENTS;
    private int preparedStatementCacheMaxSize = DEFAULT_PREPARED_STATEMENT_CACHE_MAX_SIZE;
    private int preparedStatementCacheSqlLimit = DEFAULT_PREPARED_STATEMENT_CACHE_SQL_LIMIT;
    private Map!(string, string) properties;

    this() {
        properties = new HashMap!(string, string)();
        super();
        initialize();
    }

    this(HttpURI uri) {
        version(HUNT_DEBUG) info("DB connection string: ", uri.toString());
        super(); 
        initialize();
        this.host = uri.getHost();
        this.port = uri.getPort();
        this.user = uri.getUser();
        this.password = uri.getPassword();
        string path = uri.getPath();
        assert(path.length >1);
        this.database = path[1..$];
    }

    this(SqlConnectOptions other) {
        super(other);
        initialize();
        this.host = other.host;
        this.port = other.port;
        this.user = other.user;
        this.password = other.password;
        this.database = other.database;
        this.cachePreparedStatements = other.cachePreparedStatements;
        this.preparedStatementCacheMaxSize = other.preparedStatementCacheMaxSize;
        this.preparedStatementCacheSqlLimit = other.preparedStatementCacheSqlLimit;
        this.properties = new HashMap!(string, string)(other.properties);
    }

    /**
     * Get the host for connecting to the server.
     *
     * @return the host
     */
    string getHost() {
        return host;
    }

    /**
     * Specify the host for connecting to the server.
     *
     * @param host the host to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setHost(string host) {
        assert(!host.empty(), "Host can not be null");
        this.host = host;
        return this;
    }

    /**
     * Get the port for connecting to the server.
     *
     * @return the port
     */
    int getPort() {
        return port;
    }

    /**
     * Specify the port for connecting to the server.
     *
     * @param port the port to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setPort(int port) {
        if (port < 0 || port > 65535) {
            throw new IllegalArgumentException("Port should range in 0-65535");
        }
        this.port = port;
        return this;
    }

    /**
     * Get the user account to be used for the authentication.
     *
     * @return the user
     */
    string getUser() {
        return user;
    }

    /**
     * Specify the user account to be used for the authentication.
     *
     * @param user the user to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setUser(string user) {
        assert(!host.empty, "User account can not be null");
        this.user = user;
        return this;
    }

    /**
     * Get the user password to be used for the authentication.
     *
     * @return the password
     */
    string getPassword() {
        return password;
    }

    /**
     * Specify the user password to be used for the authentication.
     *
     * @param password the password to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setPassword(string password) {
        assert(!host.empty, "Password can not be null");
        this.password = password;
        return this;
    }

    /**
     * Get the default database name for the connection.
     *
     * @return the database name
     */
    string getDatabase() {
        return database;
    }

    /**
     * Specify the default database for the connection.
     *
     * @param database the database name to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setDatabase(string database) {
        assert(!host.empty, "Database name can not be null");
        this.database = database;
        return this;
    }

    /**
     * Get whether prepared statements cache is enabled.
     *
     * @return the value
     */
    bool getCachePreparedStatements() {
        return cachePreparedStatements;
    }

    /**
     * Set whether prepared statements cache should be enabled.
     *
     * @param cachePreparedStatements true if cache should be enabled
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setCachePreparedStatements(bool cachePreparedStatements) {
        this.cachePreparedStatements = cachePreparedStatements;
        return this;
    }

    /**
     * Get the maximum number of prepared statements that the connection will cache.
     *
     * @return the size
     */
    int getPreparedStatementCacheMaxSize() {
        return preparedStatementCacheMaxSize;
    }

    /**
     * Set the maximum number of prepared statements that the connection will cache.
     *
     * @param preparedStatementCacheMaxSize the size to set
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setPreparedStatementCacheMaxSize(int preparedStatementCacheMaxSize) {
        this.preparedStatementCacheMaxSize = preparedStatementCacheMaxSize;
        return this;
    }

    /**
     * Get the maximum length of prepared statement SQL string that the connection will cache.
     *
     * @return the limit of maximum length
     */
    int getPreparedStatementCacheSqlLimit() {
        return preparedStatementCacheSqlLimit;
    }

    /**
     * Set the maximum length of prepared statement SQL string that the connection will cache.
     *
     * @param preparedStatementCacheSqlLimit the maximum length limit of SQL string to set
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setPreparedStatementCacheSqlLimit(int preparedStatementCacheSqlLimit) {
        this.preparedStatementCacheSqlLimit = preparedStatementCacheSqlLimit;
        return this;
    }

    /**
     * @return the value of current connection properties
     */
    Map!(string, string) getProperties() {
        return properties;
    }

    /**
     * Set properties for this client, which will be sent to server at the connection start.
     *
     * @param properties the value of properties to specify
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions setProperties(Map!(string, string) properties) {
        assert(properties !is null, "Properties can not be null");
        this.properties = properties;
        return this;
    }

    /**
     * Add a property for this client, which will be sent to server at the connection start.
     *
     * @param key the value of property key
     * @param value the value of property value
     * @return a reference to this, so the API can be used fluently
     */
    SqlConnectOptions addProperty(string key, string value) {
        assert(!key.empty(), "Property key can not be null");
        assert(!value.empty(), "Property value can not be null");
        this.properties.put(key, value);
        return this;
    }


    // override
    // JsonObject toJson() {
    //     JsonObject json = super.toJson();
    //     SqlConnectOptionsConverter.toJson(this, json);
    //     return json;
    // }

    /**
     * Initialize with the default options.
     */
    abstract protected void initialize();

    // protected void checkParameterNonNull(Object parameter, string message) {
    //     if (parameter is null) {
    //         throw new IllegalArgumentException(message);
    //     }
    // }
}
