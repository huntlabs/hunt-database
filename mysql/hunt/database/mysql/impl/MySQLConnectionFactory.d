module hunt.database.mysql.impl.MySQLConnectionFactory;

import hunt.database.mysql.impl.MySQLSocketConnection;
import hunt.database.mysql.MySQLConnectOptions;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.CommandResponse;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Object;

import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.NetClient;
import hunt.net.NetClientOptions;
import hunt.net.NetUtil;

/**
 * 
 */
class MySQLConnectionFactory {
    private ArrayList!NetClient clients;
    private NetClientOptions _netClientOptions;
    private string host;
    private int port;
    private string username;
    private string password;
    private string database;
    private Map!(string, string) properties;
    private bool ssl = false;
    private bool cachePreparedStatements;
    private int preparedStatementCacheSize;
    private int preparedStatementCacheSqlLimit;
    // private Closeable hook;

    this(MySQLConnectOptions options) {
        clients = new ArrayList!NetClient(50);

        _netClientOptions = new NetClientOptions(options);

        this.host = options.getHost();
        this.port = options.getPort();
        this.username = options.getUser();
        this.password = options.getPassword();
        this.database = options.getDatabase();
        this.properties = new HashMap!(string, string)(options.getProperties());
        properties.put("collation", options.getCollation());
        this.cachePreparedStatements = options.getCachePreparedStatements();
        this.preparedStatementCacheSize = options.getPreparedStatementCacheMaxSize();
        this.preparedStatementCacheSqlLimit = options.getPreparedStatementCacheSqlLimit();
    }

    // Called by hook
    private void close(AsyncVoidHandler completionHandler) {
        close();
        if(completionHandler !is null) {
            completionHandler(cast(VoidAsyncResult)null);
        }
    }

    void close() {
        foreach(client; clients)
            client.close();
    }

    void connect(AsyncResultHandler!(DbConnection) completionHandler) {
        // Promise!(NetSocket) promise = Promise.promise();
        // promise.future().setHandler(ar1 -> {
        //     if (ar1.succeeded()) {
        //         NetSocketInternal socket = (NetSocketInternal) ar1.result();
        //         MySQLSocketConnection conn = new MySQLSocketConnection(socket, cachePreparedStatements, preparedStatementCacheSize, preparedStatementCacheSqlLimit, context);
        //         conn.init();
        //         conn.sendStartupMessage(username, password, database, properties, handler);
        //     } else {
        //         handler.handle(Future.failedFuture(ar1.cause()));
        //     }
        // });
        // netClient.connect(port, host, promise);

        doConnect(false, (ar) {
            if (ar.succeeded()) {
                MySQLSocketConnection conn = ar.result();
                conn.initialization();
                import hunt.collection.AbstractMap;
                // Map!(string, string) p = (cast(AbstractMap!(string, string))properties).clone();
                auto p = cast(Map!(string, string))properties.clone();
                conn.sendStartupMessage(username, password, database, p, 
                    (r) { 
                        if(completionHandler !is null) completionHandler(r); 
                    }
                );
            } else if(completionHandler !is null) {
                completionHandler(failedResponse!(DbConnection)(ar.cause()));
            }
        });        
    }


    private void doConnect(bool ssl, AsyncResultHandler!(MySQLSocketConnection) handler) {

        auto netClient = NetUtil.createNetClient(_netClientOptions);
        netClient.setHandler(new class ConnectionEventHandler {

                MySQLSocketConnection pgConn;

                override void connectionOpened(Connection connection) {
                    version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());

                    pgConn = newSocketConnection(cast(AbstractConnection)connection);
                    handler(succeededResult(pgConn));
                }

                override void connectionClosed(Connection connection) {
                    version(HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
                    pgConn.handleClosed(connection);
                }

                override void messageReceived(Connection connection, Object message) {
                    version(HUNT_DB_DEBUG_MORE) tracef("message type: %s", typeid(message).name);
                    try {
                        pgConn.handleMessage(connection, message);
                    } catch(Throwable t) {
                        exceptionCaught(connection, t);
                    }
                }

                override void exceptionCaught(Connection connection, Throwable t) {
                    version(HUNT_DB_DEBUG) warning(t);
                    else version(HUNT_DEBUG) warning(t.msg);
                    if(pgConn !is null) {
                        pgConn.handleException(connection, t);
                    }
                    handler(failedResult!(MySQLSocketConnection)(t));
                }

                override void failedOpeningConnection(int connectionId, Throwable t) {
                    warning(t);

                    handler(failedResult!(MySQLSocketConnection)(t));
                    netClient.close(); 
                }

                override void failedAcceptingConnection(int connectionId, Throwable t) {
                    warning(t);
                    handler(failedResult!(MySQLSocketConnection)(t));
                }
            });        

        try {
            netClient.connect(host, port);
            clients.add(netClient);
        } catch (Throwable e) {
            // Client is closed
            version(HUNT_DEBUG) {
                warning(e.message);
            } else {
                warning(e);
            }
            
            if(handler !is null)
                handler(failedResult!MySQLSocketConnection(e));
        }
    }

    private MySQLSocketConnection newSocketConnection(AbstractConnection socket) {
        return new MySQLSocketConnection(socket, cachePreparedStatements, preparedStatementCacheSize, 
                preparedStatementCacheSqlLimit);
    }    
}
