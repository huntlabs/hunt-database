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

module hunt.database.mysql.impl.MySQLSocketConnection;

import io.netty.channel.ChannelPipeline;
import io.vertx.core.Context;
import io.vertx.core.Handler;
import io.vertx.core.impl.NetSocketInternal;
import hunt.database.mysql.impl.codec.MySQLCodec;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SocketConnectionBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.InitCommand;

import java.util.Map;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class MySQLSocketConnection : SocketConnectionBase {

  private MySQLCodec codec;

  MySQLSocketConnection(NetSocketInternal socket,
                               boolean cachePreparedStatements,
                               int preparedStatementCacheSize,
                               int preparedStatementCacheSqlLimit,
                               Context context) {
    super(socket, cachePreparedStatements, preparedStatementCacheSize, preparedStatementCacheSqlLimit, 1, context);
  }

  void sendStartupMessage(String username, String password, String database, Map!(String, String) properties, Handler<? super CommandResponse!(Connection)> completionHandler) {
    InitCommand cmd = new InitCommand(this, username, password, database, properties);
    cmd.handler = completionHandler;
    schedule(cmd);
  }

  override
  void init() {
    codec = new MySQLCodec();
    ChannelPipeline pipeline = socket.channelHandlerContext().pipeline();
    pipeline.addBefore("handler", "codec", codec);
    super.init();
  }
}
