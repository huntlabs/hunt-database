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
module hunt.database.postgresql.impl.pubsub.PostgreSQLSubscriberImpl;

import hunt.database.postgresql.*;
import hunt.database.postgresql.pubsub.PgSubscriber;
import hunt.database.postgresql.pubsub.PgChannel;
import io.vertx.core.*;
import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;
import io.vertx.core.streams.ReadStream;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

class PgSubscriberImpl implements PgSubscriber {

  private static Logger log = LoggerFactory.getLogger(PgSubscriberImpl.class);
  private static final Function!(Integer, Long) DEFAULT_RECONNECT_POLICY = count -> -1L;

  private final Vertx vertx;
  private final PgConnectOptions options;
  private Map!(String, ChannelList) channels = new HashMap<>();
  private Function!(Integer, Long) reconnectPolicy = DEFAULT_RECONNECT_POLICY;

  private PgConnection conn;
  private boolean connecting;
  private boolean closed = true;
  private Handler!(Void) closeHandler;

  PgSubscriberImpl(Vertx vertx, PgConnectOptions options) {
    this.vertx = vertx;
    this.options = new PgConnectOptions(options);
  }

  // Identifiers in PostgreSQL are currently limited to NAMEDATALEN-1 = 63
  // characters (see PostgreSQL lexical structure documentation)
  static final int NAMEDATALEN = 64;
  static final int MAX_CHANNEL_NAME_LENGTH = NAMEDATALEN - 1;
  static String applyIdLengthLimit(String channelName) {
  	return channelName.length() > MAX_CHANNEL_NAME_LENGTH
  			? channelName.substring(0, MAX_CHANNEL_NAME_LENGTH) : channelName;
  }

  private void handleNotification(PgNotification notif) {
    List!(Handler!(String)) handlers = new ArrayList<>();
    synchronized (this) {
      ChannelList channel = channels.get(notif.getChannel());
      if (channel !is null) {
        channel.subs.forEach(sub -> {
          if (!sub.paused) {
            Handler!(String) handler = sub.eventHandler;
            if (handler !is null) {
              handlers.add(handler);
            } else {
              // Race ?
            }
          }
        });
      } else {
        // Race ?
      }
    }
    handlers.forEach(handler -> {
      handler.handle(notif.getPayload());
    });
  }

  override
  synchronized PgSubscriber closeHandler(Handler!(Void) handler) {
    closeHandler = handler;
    return this;
  }

  override
  synchronized PgSubscriber reconnectPolicy(Function!(Integer, Long) policy) {
    if (policy is null) {
      reconnectPolicy = DEFAULT_RECONNECT_POLICY;
    } else {
      reconnectPolicy = policy;
    }
    return this;
  }

  private synchronized void handleClose(Void v) {
    conn = null;
    checkReconnect(0);
  }

  private void checkReconnect(int count) {
    if (!closed) {
      Long val = reconnectPolicy.apply(count);
      if (val >= 0) {
        tryConnect(val, ar -> {
          if (ar.failed()) {
            checkReconnect(count + 1);
          }
        });
        return;
      }
      closed = true;
    }
    List!(Handler!(Void)) all = channels
      .values()
      .stream()
      .flatMap(channel -> channel.subs.stream())
      .map(sub -> sub.endHandler)
      .filter(Objects::nonNull)
      .collect(Collectors.toList());
    channels.clear();
    all.forEach(handler -> handler.handle(null));
    Handler!(Void) handler = closeHandler;
    if (handler !is null) {
      handler.handle(null);
    }
  }

  override
  synchronized boolean closed() {
    return closed;
  }

  override
  synchronized PgConnection actualConnection() {
    return conn;
  }

  override
  synchronized PgSubscriber connect(Handler!(AsyncResult!(Void)) handler) {
    if (closed) {
      closed = false;
      tryConnect(0, handler);
    }
    return this;
  }

  private void tryConnect(long delayMillis, Handler!(AsyncResult!(Void)) handler) {
    if (!connecting) {
      connecting = true;
      if (delayMillis > 0) {
        vertx.setTimer(delayMillis, v -> doConnect(handler));
      } else {
        doConnect(handler);
      }
    }
  }

  private void doConnect(Handler!(AsyncResult!(Void)) completionHandler) {
    PgConnection.connect(vertx, options, ar -> handleConnectResult(completionHandler, ar));
  }

  private synchronized void handleConnectResult(Handler!(AsyncResult!(Void)) completionHandler, AsyncResult!(PgConnection) ar1) {
    connecting = false;
    if (ar1.succeeded()) {
      conn = ar1.result();
      conn.notificationHandler(PgSubscriberImpl.this::handleNotification);
      conn.closeHandler(PgSubscriberImpl.this::handleClose);
      if (channels.size() > 0) {
        List!(Handler!(Void)) handlers = channels.values()
          .stream()
          .flatMap(channel -> channel.subs.stream())
          .map(sub -> sub.subscribeHandler)
          .filter(Objects::nonNull)
          .collect(Collectors.toList());
        String sql = channels.values()
          .stream()
          .map(channel -> {
            channel.subscribed = true;
            return channel.quotedName;
          })
          .collect(Collectors.joining(";LISTEN ", "LISTEN ", ""));
        conn.query(sql, ar2 -> {
          if (ar2.failed()) {
            log.error("Cannot LISTEN to channels", ar2.cause());
            conn.close();
          } else {
            handlers.forEach(vertx::runOnContext);
          }
          completionHandler.handle(ar2.mapEmpty());
        });
        return;
      }
    }
    completionHandler.handle(ar1.mapEmpty());
  }

  private class ChannelList {

    final String name;
	final String quotedName;
    final ArrayList!(ChannelImpl) subs = new ArrayList<>();
    boolean subscribed;

    ChannelList(String name) {
      this.name = name;
	  quotedName = "\"" ~ name.replace("\"", "\"\"") ~ "\"";
    }

    void add(ChannelImpl sub) {
      subs.add(sub);
      if (!subscribed) {
        if (conn !is null) {
          subscribed = true;
          String sql = "LISTEN " ~ quotedName;
          conn.query(sql, ar -> {
            if (ar.succeeded()) {
              Handler!(Void) handler = sub.subscribeHandler;
              if (handler !is null) {
                handler.handle(null);
              }
            } else {
              log.error("Cannot LISTEN to channel " ~ name, ar.cause());
            }
          });
        }
      }
    }

    void remove(ChannelImpl sub) {
      subs.remove(sub);
      if (subs.isEmpty()) {
        channels.remove(name, this);
        if (conn !is null) {
          conn.query("UNLISTEN " ~ quotedName, ar -> {
            if (ar.failed()) {
              log.error("Cannot UNLISTEN channel " ~ name, ar.cause());
            }
          });
        }
      }
    }
  }

  private class ChannelImpl implements PgChannel {

    private final String name;
    private Handler!(Void) subscribeHandler;
    private Handler!(String) eventHandler;
    private Handler!(Void) endHandler;
    private ChannelList channel;
    private boolean paused;

    ChannelImpl(String name) {
      this.name = applyIdLengthLimit(name);
    }

    override
    PgChannel subscribeHandler(Handler!(Void) handler) {
      synchronized (PgSubscriberImpl.this) {
        subscribeHandler = handler;
      }
      return this;
    }

    override
    ChannelImpl exceptionHandler(Handler!(Throwable) handler) {
      return this;
    }

    override
    ChannelImpl handler(Handler!(String) handler) {
      synchronized (PgSubscriberImpl.this) {
        if (handler !is null) {
          eventHandler = handler;
          if (channel is null) {
            channel = channels.computeIfAbsent(name, ChannelList::new);
            channel.add(this);
          }
        } else {
          if (channel !is null) {
            ChannelList ch = channel;
            channel = null;
            ch.remove(this);
            Handler!(Void) _handler = endHandler;
            if (_handler !is null) {
              _handler.handle(null);
            }
          }
        }
      }
      return this;
    }

    override
    ChannelImpl endHandler(Handler!(Void) handler) {
      synchronized (PgSubscriberImpl.this) {
        endHandler = handler;
      }
      return this;
    }

    override
    ChannelImpl pause() {
      synchronized (PgSubscriberImpl.this) {
        paused = true;
      }
      return this;
    }

    override
    ChannelImpl resume() {
      synchronized (PgSubscriberImpl.this) {
        paused = false;
      }
      return this;
    }

    // Since Vert.x 3.6.0 : todo
    ReadStream!(String) fetch(long amount) {
      throw new UnsupportedOperationException();
    }
  }

  override
  void close() {
    synchronized (PgSubscriberImpl.this) {
      if (!closed) {
        closed = true;
        if (conn !is null) {
          conn.close();
        }
      }
    }
  }

  override
  PgChannel channel(String name) {
    return new ChannelImpl(name);
  }
}
