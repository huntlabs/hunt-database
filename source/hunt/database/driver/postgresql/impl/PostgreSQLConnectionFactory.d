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

module hunt.database.driver.postgresql.impl.PostgreSQLConnectionFactory;

import hunt.database.driver.postgresql.impl.codec.PgCodec;
import hunt.database.driver.postgresql.impl.PostgreSQLSocketConnection;
import hunt.database.driver.postgresql.PostgreSQLConnectOptions;
import hunt.database.driver.postgresql.SslMode;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.CommandResponse;

import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.io.BufferUtils;
import hunt.io.channel;
import hunt.logging.ConsoleLogger;
import hunt.Object;

import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.NetClient;
import hunt.net.NetClientOptions;
import hunt.net.NetUtil;


/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PgConnectionFactory {

    private ArrayList!NetClient clients;
    private NetClientOptions _netClientOptions;
    private bool registerCloseHook;
    private string host;
    private int port;
    private SslMode sslMode;
    // private TrustOptions trustOptions;
    private string hostnameVerificationAlgorithm;
    private string database;
    private string username;
    private string password;
    private Map!(string, string) properties;
    private bool cachePreparedStatements;
    private int preparedStatementCacheSize;
    private int preparedStatementCacheSqlLimit;
    private int pipeliningLimit;
    private bool isUsingDomainSocket;
    // private Closeable hook;

    this(PgConnectOptions options) {
        // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-10-13T10:17:49+08:00
        // remove clients
        clients = new ArrayList!NetClient(50);
        _netClientOptions = new NetClientOptions(options);

        // Make sure ssl=false as we will use STARTLS
        _netClientOptions.setSsl(false);

        this.sslMode = options.getSslMode();
        this.hostnameVerificationAlgorithm = _netClientOptions.getHostnameVerificationAlgorithm();
        // this.trustOptions = netClientOptions.getTrustOptions();
        this.host = options.getHost();
        this.port = options.getPort();
        this.database = options.getDatabase();
        this.username = options.getUser();
        this.password = options.getPassword();
        this.properties = new HashMap!(string, string)(options.getProperties());
        this.cachePreparedStatements = options.getCachePreparedStatements();
        this.pipeliningLimit = options.getPipeliningLimit();
        this.preparedStatementCacheSize = options.getPreparedStatementCacheMaxSize();
        this.preparedStatementCacheSqlLimit = options.getPreparedStatementCacheSqlLimit();
        this.isUsingDomainSocket = options.isUsingDomainSocket();
    }

    // Called by hook
    private void close(AsyncVoidHandler completionHandler) {
        close();
        if(completionHandler !is null) {
            completionHandler(null);
        }
    }

    void close() {
        foreach(NetClient client; clients) {
            if(client !is null) {
            // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-10-12T10:26:30+08:00
            // crashed here
                // warning(typeid(cast(Object)client));
                client.close();
            }
        }
    }

    void connectAndInit(AsyncResultHandler!(DbConnection) completionHandler) {
        connect( (ar) {
            if (ar.succeeded()) {
                PgSocketConnection conn = ar.result();
                conn.initialization();
                conn.sendStartupMessage(username, password, database, properties, 
                    (r) { 
                        if(completionHandler !is null) completionHandler(r); 
                    }
                );
            } else if(completionHandler !is null) {
                completionHandler(failedResponse!(DbConnection)(ar.cause()));
            } else {
                warning("do nothing");
            }
        });
    }

    void connect(AsyncResultHandler!(PgSocketConnection) handler) {
        doConnect(false, handler);
        // switch (sslMode) {
        //     case DISABLE:
        //         doConnect(false, handler);
        //         break;
        //     case ALLOW:
        //         doConnect(false, ar -> {
        //             if (ar.succeeded()) {
        //                 handler.handle(Future.succeededFuture(ar.result()));
        //             } else {
        //                 doConnect(true, handler);
        //             }
        //         });
        //         break;
        //     case PREFER:
        //         doConnect(true, ar -> {
        //             if (ar.succeeded()) {
        //                 handler.handle(Future.succeededFuture(ar.result()));
        //             } else {
        //                 doConnect(false, handler);
        //             }
        //         });
        //         break;
        //     case VERIFY_FULL:
        //         if (hostnameVerificationAlgorithm is null || hostnameVerificationAlgorithm.isEmpty()) {
        //             handler.handle(Future.failedFuture(new IllegalArgumentException("Host verification algorithm must be specified under verify-full sslmode")));
        //             return;
        //         }
        //     case VERIFY_CA:
        //         if (trustOptions is null) {
        //             handler.handle(Future.failedFuture(new IllegalArgumentException("Trust options must be specified under verify-full or verify-ca sslmode")));
        //             return;
        //         }
        //     case REQUIRE:
        //         doConnect(true, handler);
        //         break;
        //     default:
        //         throw new IllegalArgumentException("Unsupported SSL mode");
        // }
    }

    private void doConnect(bool ssl, AsyncResultHandler!(PgSocketConnection) handler) {

        version(HUNT_DB_DEBUG) tracef("Creating a DB connection in %s...", _netClientOptions.getConnectTimeout);

        auto client = NetUtil.createNetClient(_netClientOptions);

        client.setHandler(new class NetConnectionHandler {

                PgSocketConnection pgConn;

                override void connectionOpened(Connection connection) {
                    version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
                    AbstractConnection ac = cast(AbstractConnection)connection;
                    ac.setState(ConnectionState.Opened);

                    pgConn = newSocketConnection(ac);
                    if(handler !is null) {
                        try {
                            handler(succeededResult(pgConn));
                        } catch(Throwable ex) {
                            version(HUNT_DB_DEBUG_MORE) warning(ex);
                            handler(failedResult!(PgSocketConnection)(ex));
                        }
                    }
                }

                override void connectionClosed(Connection connection) {
                    version(HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
                    if(pgConn !is null)
                        pgConn.handleClosed(connection);
                }

                override DataHandleStatus messageReceived(Connection connection, Object message) {
                    DataHandleStatus resultStatus = DataHandleStatus.Done;
                    version(HUNT_DB_DEBUG_MORE) tracef("message type: %s", typeid(message).name);
                    try {
                        // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-01-26T14:46:35+08:00
                        // 
                        pgConn.handleMessage(connection, message);
                    } catch(Throwable t) {
                        exceptionCaught(connection, t);
                    }

                    return resultStatus;
                }

                override void exceptionCaught(Connection connection, Throwable t) {
                    version(HUNT_DEBUG) warning(t.msg);
                    version(HUNT_DB_DEBUG) warning(t);
                    if(pgConn !is null) {
                        pgConn.handleException(connection, t);
                    }
                    if(handler !is null) {
                        handler(failedResult!(PgSocketConnection)(t));
                    }
                }

                override void failedOpeningConnection(int connectionId, Throwable t) {
                    warning(t);

                    handler(failedResult!(PgSocketConnection)(t));
                    client.close(); 
                }

                override void failedAcceptingConnection(int connectionId, Throwable t) {
                    warning(t);
                    handler(failedResult!(PgSocketConnection)(t));
                }
            });        


        version(HUNT_DB_DEBUG) {
            trace("Setting PostgreSQL codec");
        }
        client.setCodec(new PgCodec());

        try {
            client.connect(host, port);
            clients.add(client);
        } catch (Throwable e) {
            // Client is closed
            version(HUNT_DEBUG) {
                warning(e.message);
            } else {
                warning(e);
            }
            
            if(handler !is null)
                handler(failedResult!PgSocketConnection(e));
        }
    }

    private PgSocketConnection newSocketConnection(AbstractConnection socket) {
        return new PgSocketConnection(socket, cachePreparedStatements, preparedStatementCacheSize, 
                preparedStatementCacheSqlLimit, pipeliningLimit);
    }
}
