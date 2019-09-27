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

module hunt.database.driver.postgresql.impl.PostgreSQLSocketConnection;

import hunt.database.driver.postgresql.impl.codec.PgCodec;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SocketConnectionBase;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.InitCommand;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.AbstractConnection;
import hunt.net.Exceptions;
import hunt.util.Common;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PgSocketConnection : SocketConnectionBase {

    // private PgCodec codec;
    int processId;
    int secretKey;

    // default value for server versions that don't report standard_conforming_strings
    private bool _standardConformingStrings = false;

    this(AbstractConnection socket,
            bool cachePreparedStatements,
            int preparedStatementCacheSize,
            int preparedStatementCacheSqlLimit,
            int pipeliningLimit) {
                
        super(socket, cachePreparedStatements, preparedStatementCacheSize, 
                preparedStatementCacheSqlLimit, pipeliningLimit);
    }

    // override
    // void initialization() {
    //     codec = new PgCodec();
    //     version(HUNT_DEBUG) {
    //         trace("Setting DB codec");
    //     }
    //     socket().setCodec(codec);
    //     super.initialization();
    // }

    void sendStartupMessage(string username, string password, string database, Map!(string, string) properties,
            ResponseHandler!(DbConnection) completionHandler) {
        InitCommand cmd = new InitCommand(this, username, password, database, properties);
        cmd.handler = completionHandler;
        version(HUNT_DEBUG) {
            trace("Sending InitCommand");
        }
        schedule(cmd);
    }

    void sendCancelRequestMessage(int processId, int secretKey, Callback handler) {
        ByteBuffer buffer = BufferUtils.allocate(16);
        buffer.putInt(16);
        // cancel request code
        buffer.putInt(80877102);
        buffer.putInt(processId);
        buffer.putInt(secretKey);

        socket.write(buffer, new class Callback {

            void succeeded() {
                // directly close this connection
                if (status == Status.CONNECTED) {
                    status = Status.CLOSING;
                    socket.close();
                }
                handler.succeeded();
            }

            void failed(Exception x) {
                // handler(Future.failedFuture(ar.cause()));
                handler.failed(x);
            }

            bool isNonBlocking() {
                return true;
            }
        });
    }

    override
    int getProcessId() {
        return processId;
    }

    override
    int getSecretKey() {
        return secretKey;
    }

    void setStandardConformingStrings(bool value) {
        _standardConformingStrings = value;
    }

    bool getStandardConformingStrings() {
        return _standardConformingStrings;
    }

    void upgradeToSSLConnection(Callback completionHandler) {
        // ChannelPipeline pipeline = socket.channelHandlerContext().pipeline();
        // Promise!(Void) upgradePromise = Promise.promise();
        // upgradePromise.future().setHandler(ar->{
        //     if (ar.succeeded()) {
        //         completionHandler.handle(Future.succeededFuture());
        //     } else {
        //         Throwable cause = ar.cause();
        //         if (cause instanceof DecoderException) {
        //             DecoderException err = (DecoderException) cause;
        //             cause = err.getCause();
        //         }
        //         completionHandler.handle(Future.failedFuture(cause));
        //     }
        // });
        // pipeline.addBefore("handler", "initiate-ssl-handler", new InitiateSslHandler(this, upgradePromise));
        // TODO: Tasks pending completion -@zxp at 8/14/2019, 11:42:27 AM
        // 
        implementationMissing(false);
    }

}
