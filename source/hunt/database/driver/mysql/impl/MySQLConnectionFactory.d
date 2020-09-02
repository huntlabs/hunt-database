module hunt.database.driver.mysql.impl.MySQLConnectionFactory;

import hunt.database.driver.mysql.impl.codec.MySQLCodec;
import hunt.database.driver.mysql.impl.MySQLSocketConnection;
import hunt.database.driver.mysql.MySQLConnectOptions;

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

import core.thread;

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

        clients.clear();
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

        NetClient netClient = NetUtil.createNetClient(_netClientOptions);

        netClient.setHandler(new class NetConnectionHandler {

                MySQLSocketConnection myConn;

                override void connectionOpened(Connection connection) {
                    version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
// FIXME: Needing refactor or cleanup -@zhangxueping at 2019-09-25T11:26:40+08:00
// 
                    if(myConn is null) {
                        myConn = newSocketConnection(cast(AbstractConnection)connection);
                        if(handler !is null) 
                            handler(succeededResult(myConn));
                    } else {
                        warning("MySQLSocketConnection has been opened already.");
                    }
                }

                override void connectionClosed(Connection connection) {
                    version(HUNT_DEBUG) infof("The DB connection closed, remote: %s", connection.getRemoteAddress());
                    if(myConn !is null)
                        myConn.handleClosed(connection);
                    
                    // 
                    synchronized(this.outer) {
                        clients.remove(netClient);
                    }
                    // destroy(netClient);
                    version(HUNT_DB_DEBUG) {
                        infof("Remaining clients: %d, threads: %d", 
                            clients.size(), Thread.getAll().length);
                    }
                }

                override void messageReceived(Connection connection, Object message) {
                    version(HUNT_DB_DEBUG_MORE) tracef("message type: %s", typeid(message).name);
                    if(myConn is null) {
                        // warningf("Waiting for the MySQLSocketConnection get ready");
                        version(HUNT_DEBUG) warningf("MySQLSocketConnection is not ready.");
                        
                        // import std.stdio;
                        while(myConn is null) {
                            // warningf("Waiting for the MySQLSocketConnection get ready...");
                            // write(".");
                        }
                        version(HUNT_DEBUG) warningf("MySQLSocketConnection is ready.");
                    }

                    try {
                        myConn.handleMessage(connection, message);
                    } catch(Throwable t) {
                        exceptionCaught(connection, t);
                    }
                }

                override void exceptionCaught(Connection connection, Throwable t) {
                    version(HUNT_DB_DEBUG) warning(t);
                    else version(HUNT_DEBUG) warning(t.msg);
                    
                    if(myConn !is null) {
                        myConn.handleException(connection, t);
                    }
                    if(handler !is null)
                        handler(failedResult!(MySQLSocketConnection)(t));
                    
                    synchronized(this.outer) {
                        clients.remove(netClient);
                    }
                    destroy(netClient);
                    version(HUNT_DB_DEBUG) {
                        infof("Remaining clients: %d, threads: %d", 
                            clients.size(), Thread.getAll().length);
                    }
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

        version(HUNT_DEBUG) {
            trace("Setting MySQL codec");
        }
        netClient.setCodec(new MySQLCodec());     

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
