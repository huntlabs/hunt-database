/*
 * Copyright (C) 2018 Julien Viet
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
module hunt.database.postgresql.impl.codec.InitCommandCodec;

import hunt.database.postgresql.impl.codec.ErrorResponse;
import hunt.database.postgresql.impl.codec.PgCommandCodec;
import hunt.database.postgresql.impl.codec.PgEncoder;

import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.InitCommand;
import hunt.database.postgresql.impl.PostgreSQLSocketConnection;

// import java.nio.charset.Charset;
// import java.nio.charset.StandardCharsets;

class InitCommandCodec : PgCommandCodec!(Connection, InitCommand) {

    private PgEncoder encoder;
    private string encoding;

    this(InitCommand cmd) {
        super(cmd);
    }

    override
    void encode(PgEncoder encoder) {
        this.encoder = encoder;
        encoder.writeStartupMessage(new StartupMessage(cmd.username(), cmd.database(), cmd.properties()));
    }

    override
    void handleAuthenticationMD5Password(byte[] salt) {
        encoder.writePasswordMessage(new PasswordMessage(cmd.username(), cmd.password(), salt));
        encoder.flush();
    }

    override
    void handleAuthenticationClearTextPassword() {
        encoder.writePasswordMessage(new PasswordMessage(cmd.username(), cmd.password(), null));
        encoder.flush();
    }

    override
    void handleAuthenticationOk() {
//      handler.handle(Future.succeededFuture(conn));
//      handler = null;
    }

    override
    void handleParameterStatus(string key, string value) {
        if(key == "client_encoding") {
            encoding = value;
        }
    }

    override
    void handleBackendKeyData(int processId, int secretKey) {
        (cast(PgSocketConnection)cmd.connection()).processId = processId;
        (cast(PgSocketConnection)cmd.connection()).secretKey = secretKey;
    }

    override
    void handleErrorResponse(ErrorResponse errorResponse) {
        CommandResponse!(Connection) resp = CommandResponse.failure(errorResponse.toException());
        completionHandler.handle(resp);
    }

    override
    void handleReadyForQuery(TxStatus txStatus) {
        // The final phase before returning the connection
        // We should make sure we are supporting only UTF8
        // https://www.postgresql.org/docs/9.5/static/multibyte.html#MULTIBYTE-CHARSET-SUPPORTED
        // Charset cs = null;
        // try {
        //     cs = Charset.forName(encoding);
        // } catch (Exception ignore) {
        // }
        CommandResponse!(Connection) fut;
        if(encoding != "UTF_8") {
            fut = CommandResponse.failure(encoding ~ " is not supported in the client only UTF8");
        } else {
            fut = CommandResponse.success(cmd.connection());
        }
        completionHandler.handle(fut);
    }
}
