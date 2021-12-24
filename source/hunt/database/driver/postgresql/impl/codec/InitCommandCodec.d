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
module hunt.database.driver.postgresql.impl.codec.InitCommandCodec;

import hunt.database.driver.postgresql.impl.codec.ErrorResponse;
import hunt.database.driver.postgresql.impl.codec.PasswordMessage;
import hunt.database.driver.postgresql.impl.codec.CommandCodec;
import hunt.database.driver.postgresql.impl.codec.PgEncoder;
import hunt.database.driver.postgresql.impl.codec.StartupMessage;

import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.command.InitCommand;
import hunt.database.driver.postgresql.impl.PostgreSQLSocketConnection;

import hunt.logging;
import hunt.Exceptions;

class InitCommandCodec : CommandCodec!(DbConnection, InitCommand) {

    private PgEncoder encoder;
    private string encoding;
    private PgSocketConnection pgConnection;

    this(InitCommand cmd) {
        super(cmd);
        pgConnection = cast(PgSocketConnection)cmd.connection();
    }

    override
    void encode(PgEncoder encoder) {
        version(HUNT_DB_DEBUG) tracef("encoding...");
        this.encoder = encoder;
        encoder.writeStartupMessage(new StartupMessage(cmd.username(), cmd.database(), cmd.properties()));
        // encoder.flush();
    }

    override
    void handleAuthenticationMD5Password(byte[] salt) {
        version(HUNT_DB_DEBUG_MORE) tracef("salt: %(%02X %)", salt);
        encoder.writePasswordMessage(new PasswordMessage(cmd.username(), cmd.password(), salt));
        encoder.flush();
    }

    override
    void handleAuthenticationClearTextPassword() {
        version(HUNT_DB_DEBUG) tracef("running here");
        encoder.writePasswordMessage(new PasswordMessage(cmd.username(), cmd.password(), null));
        encoder.flush();
    }

    override
    void handleAuthenticationOk() {
        version(HUNT_DB_DEBUG) info("TODO: Authentication done.");
        // TODO: Tasks pending completion -@zxp at Fri, 20 Sep 2019 02:31:50 GMT
        // Return the server setup information.
//      handler.handle(Future.succeededFuture(conn));
//      handler = null;
    }

    override
    void handleParameterStatus(string name, string value) {
        version(HUNT_DB_DEBUG_MORE) tracef("key: %s, value: %s", name, value);
        // FIXME: Needing refactor or cleanup -@zxp at Fri, 20 Sep 2019 02:25:36 GMT
        // handle more status
        // pgjdbc\src\main\java\org\postgresql\core\v3\QueryExecutorImpl.java

        switch(name) {
            case "client_encoding":
                encoding = value; break;

            case "standard_conforming_strings":
                pgConnection.setStandardConformingStrings(value == "on");
                break;

            default: break;
        }

        if (name == "standard_conforming_strings") {

        }
    }

    override
    void handleBackendKeyData(int processId, int secretKey) {
        version(HUNT_DB_DEBUG) tracef("processId: %d, secretKey: %d", processId, secretKey);
        pgConnection.processId = processId;
        pgConnection.secretKey = secretKey;
    }

    override
    void handleErrorResponse(ErrorResponse errorResponse) {
        version(HUNT_DB_DEBUG) warningf("errorResponse: %s", errorResponse.toString());
        CommandResponse!(DbConnection) resp = failedResponse!DbConnection(errorResponse.toException());
        if(completionHandler !is null) {
            // resp.cmd = cmd;
            completionHandler(resp);
        }
    }

    override
    void handleReadyForQuery(TxStatus txStatus) {
        version(HUNT_DB_DEBUG) tracef("txStatus: %s, encoding: %s", txStatus, encoding);
        // The final phase before returning the connection
        // We should make sure we are supporting only UTF8
        // https://www.postgresql.org/docs/9.5/static/multibyte.html#MULTIBYTE-CHARSET-SUPPORTED
        // Charset cs = null;
        // try {
        //     cs = Charset.forName(encoding);
        // } catch (Exception ignore) {
        // }

        if(completionHandler !is null) {
            CommandResponse!(DbConnection) resp;
            if(encoding != "UTF8") {
                resp = failedResponse!(DbConnection)(encoding ~ " is not supported in the client only UTF8");
            } else {
                resp = succeededResponse!(DbConnection)(cmd.connection());
            }
            // resp.cmd = cmd;
            completionHandler(resp);
        }
    }
}
