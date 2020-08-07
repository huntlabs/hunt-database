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

module hunt.database.base.impl.SocketConnectionBase;

import hunt.database.base.impl.command;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.Notice;
import hunt.database.base.impl.Notification;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.PreparedStatementCache;
import hunt.database.base.impl.StringLongSequence;

import hunt.collection.ArrayDeque;
import hunt.collection.Deque;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.Exceptions;
import hunt.Object;
import hunt.util.TypeUtils;

import std.container.dlist;
import std.conv;
import std.range;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class SocketConnectionBase : DbConnection {

    // private static final Logger logger = LoggerFactory.getLogger(SocketConnectionBase.class);

    enum Status {
        CLOSED, CONNECTED, CLOSING
    }

    protected PreparedStatementCache psCache;
    private int preparedStatementCacheSqlLimit;
    private StringLongSequence psSeq; // = new StringLongSequence();
    // private ArrayDeque<CommandBase<?>> pending = new ArrayDeque<>();
    private DList!(ICommand) pending;
    
    private int inflight;
    private Holder holder;
    private int pipeliningLimit;

    protected AbstractConnection _socket;
    protected Status status = Status.CONNECTED;

    this(AbstractConnection socket,
                        bool cachePreparedStatements,
                        int preparedStatementCacheSize,
                        int preparedStatementCacheSqlLimit,
                        int pipeliningLimit) {
        this._socket = socket;
        this.psSeq = new StringLongSequence();
        this.pipeliningLimit = pipeliningLimit;
        this.psCache = cachePreparedStatements ? new PreparedStatementCache(preparedStatementCacheSize, this) : null;
        this.preparedStatementCacheSqlLimit = preparedStatementCacheSqlLimit;
    }

    void initialization() {

        // ConnectionEventHandlerAdapter adapter = new ConnectionEventHandlerAdapter();
        // adapter.onClosed(&handleClosed);
        // adapter.onException(&handleException);
        // adapter.onMessageReceived((Connection conn, Object msg) {
        //     version(HUNT_DB_DEBUG) tracef("A message received. %s", typeid(msg));
        //     try {
        //         handleMessage(conn, msg);
        //     } catch (Throwable e) {
        //         handleException(conn, e);
        //     }
        // });

        // _socket.setHandler(adapter);
    }

    AbstractConnection socket() {
        return _socket;
    }

    bool isSsl() {
        return _socket.isSecured();
    }

    override
    void initHolder(Holder holder) {
        this.holder = holder;
    }

    override
    int getProcessId() {
        return _socket.getId();
    }

    override
    int getSecretKey() {
        throw new UnsupportedOperationException();
    }

    override
    void close(Holder holder) {

        version(HUNT_DB_DEBUG) infof("closing socket... status: %s", status);

        if (status == Status.CONNECTED) {
            status = Status.CLOSING;
            _socket.close();
            // // Append directly since schedule checks the status and won't enqueue the command
            // pending.add(CloseConnectionCommand.INSTANCE);
            // checkPending();            
        }
        // if (Vertx.currentContext() == context) {
        //     if (status == Status.CONNECTED) {
        //         status = Status.CLOSING;
        //         // Append directly since schedule checks the status and won't enqueue the command
        //         pending.add(CloseConnectionCommand.INSTANCE);
        //         checkPending();
        //     }
        // } else {
        //     context.runOnContext(v -> close(holder));
        // }
    }

    void schedule(ICommand cmd) {
        if (!cmd.handlerExist()) {
            version(HUNT_DEBUG) warningf(typeid(cast(Object)cmd).toString());
            throw new IllegalArgumentException("No handler exists in command." ~ 
                TypeUtils.getSimpleName(typeid(cast(Object)cmd)));
        }

        // Special handling for cache
        PreparedStatementCache psCache = this.psCache;
        PrepareStatementCommand psCmd = cast(PrepareStatementCommand) cmd;
        if (psCache !is null && psCmd !is null) {
            if (psCmd.sql().length > preparedStatementCacheSqlLimit) {
                // do not cache the statements
                return;
            }
            CachedPreparedStatement cached = psCache.get(psCmd.sql());
            if (cached !is null) {
                psCmd.cached = cached;
                ResponseHandler!(PreparedStatement) handler = psCmd.handler;
                cached.get(handler);
                return;
            }

            if (psCache.size() >= psCache.getCapacity() && !psCache.isReady()) {
                // only if the prepared statement is ready then it can be evicted
                version(HUNT_DB_DEBUG) info("do nothing");
            } else {
                psCmd._statement = psSeq.next();
                psCmd.cached = cached = new CachedPreparedStatement();
                psCache.put(psCmd.sql(), cached);
                ResponseHandler!(PreparedStatement) a = psCmd.handler;
                (cast(CachedPreparedStatement) cached).get(a);
                psCmd.handler = (CommandResponse!(PreparedStatement) r) { cached.handle(r); };
            }
        }

        //
        if (status == Status.CONNECTED) {
            pending.insertBack(cmd);
            checkPending();
        } else {
            cmd.fail(new IOException("Connection not open " ~ status.to!string()));
        }
    }


    private void checkPending() {
        if (inflight < pipeliningLimit) {
            ICommand cmd;
            while (inflight < pipeliningLimit && (cmd = pollPending()) !is null) {
                inflight++;
                version(HUNT_DB_DEBUG_MORE) {
                    // tracef("chekcing %s ... ", typeid(cast(Object)cmd));
                } else version(HUNT_DB_DEBUG) {
                    // trace("chekcing... ");
                } 
                _socket.encode(cast(Object)cmd);
            }
        }
    }

    private ICommand pollPending() {
        if(pending.empty())
            return null;
        ICommand c = pending.front;
        pending.removeFront();
        return c;

    }

    void handleMessage(Connection conn, Object msg) {
        version(HUNT_DB_DEBUG_MORE) tracef("handling a message: %s", typeid(msg));

        ICommandResponse resp = cast(ICommandResponse) msg;
        if (resp !is null) {
            inflight--;
            checkPending();
            resp.notifyCommandResponse();
            version(HUNT_DB_DEBUG_MORE) tracef("inflight=%d", inflight);
            return;
        } 

        Notification n = cast(Notification) msg;
        if (n !is null) {
            handleNotification(n);
            return;
        }

        Notice notice = cast(Notice) msg;
        if (notice !is null) {
            handleNotice(notice);
        }

        version(HUNT_DB_DEBUG) warningf("Unhandled message: %s", typeid(msg));
    }

    private void handleNotification(Notification response) {
        if (holder !is null) {
            holder.handleNotification(response.getProcessId(), response.getChannel(), response.getPayload());
        }
    }

    private void handleNotice(Notice notice) {
        notice.log();
    }

    void handleClosed(Connection conn) {
        handleClose(cast(Throwable)null);
    }

    void handleException(Connection c, Throwable t) {
        DecoderException err = cast(DecoderException) t;
        if (err !is null) {
            t = err.next;
        }
        handleClose(t);
    }

    private void handleClose(Throwable t) {
        version(HUNT_DEBUG) {
            infof("Connection closed. Throwable: %s", t is null);
        }
        if (status != Status.CLOSED) {
            status = Status.CLOSED;
            if (t !is null) {
                synchronized (this) {
                    if (holder !is null) {
                        holder.handleException(t);
                    }
                }
            }

            version(HUNT_DB_DEBUG) {
                if(holder !is null) {
                    tracef("pending: %d, holder: %s", pending[].walkLength(), typeid(cast(Object)holder));
                }
            }

            Throwable cause = t is null ? new Exception("closed") : t;
            ICommand cmd;
            while ((cmd = pollPending()) !is null) {
                ICommand c = cmd;
                c.fail(cause);
            }

            if (holder !is null) {
                holder.handleClosed();
            }
        }
    }
}

