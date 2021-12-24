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
module hunt.database.driver.postgresql.impl.codec.CommandCodec;

import hunt.database.driver.postgresql.impl.codec.ErrorResponse;
import hunt.database.driver.postgresql.impl.codec.NoticeResponse;
import hunt.database.driver.postgresql.impl.codec.PgParamDesc;
import hunt.database.driver.postgresql.impl.codec.PgEncoder;
import hunt.database.driver.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.Common;
import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;

import hunt.Exceptions;
import hunt.logging;
import hunt.net.buffer.ByteBuf;


/**
*/
abstract class CommandCodecBase {
    
    Throwable _failure;
    
    EventHandler!(NoticeResponse) noticeHandler;
    EventHandler!(ICommandResponse) completionHandler;

    abstract void encode(PgEncoder encoder);

    void decodeRow(int len, ByteBuf inBuffer) {
        throw new NotImplementedException();
    }

    void handleBackendKeyData(int processId, int secretKey) {
        warning(typeid(this).name ~ " should handle message BackendKeyData");
    }

    void handleEmptyQueryResponse() {
        warning(typeid(this).name ~ " should handle message EmptyQueryResponse");
    }

    void handleParameterDescription(PgParamDesc paramDesc) {
        warning(typeid(this).name ~ " should handle message ParameterDescription");
    }

    void handleParseComplete() {
        warning(typeid(this).name ~ " should handle message ParseComplete");
    }

    void handleCloseComplete() {
        warning(typeid(this).name ~ " should handle message CloseComplete");
    }

    void handleRowDescription(PgRowDesc rowDescription) {
        warning(typeid(this).name ~ " should handle message " ~ rowDescription.toString());
    }

    void handleNoData() {
        warning(typeid(this).name ~ " should handle message NoData");
    }

    void handleNoticeResponse(NoticeResponse noticeResponse);

    void handleErrorResponse(ErrorResponse errorResponse) {
        warning(typeid(this).name ~ " should handle message " ~ errorResponse.toString());
    }

    void handlePortalSuspended() {
        warning(typeid(this).name ~ " should handle message PortalSuspended");
    }

    void handleBindComplete() {
        warning(typeid(this).name ~ " should handle message BindComplete");
    }

    void handleCommandComplete(int updated) {
        warning(typeid(this).name ~ " should handle message CommandComplete");
    }

    void handleAuthenticationMD5Password(byte[] salt) {
        warning(typeid(this).name ~ " should handle message AuthenticationMD5Password");
    }

    void handleAuthenticationClearTextPassword() {
        warning(typeid(this).name ~ " should handle message AuthenticationClearTextPassword");
    }

    void handleAuthenticationOk() {
        warning(typeid(this).name ~ " should handle message AuthenticationOk");
    }

    void handleParameterStatus(string key, string value) {
        warning(typeid(this).name ~ " should handle message ParameterStatus");
    }

    void handleReadyForQuery(TxStatus txStatus);

    ICommand getCommand();
}

/**
*/
abstract class CommandCodec(R, C) : CommandCodecBase
        if(is(C : CommandBase!(R))) {

    R result;
    C cmd;

    this(C cmd) {
        this.cmd = cmd;
    }

    /**
     * <p>
     * The frontend can issue commands. Every message returned from the backend has transaction status
     * that would be one of the following
     * <p>
     * IDLE : Not in a transaction block
     * <p>
     * ACTIVE : In transaction block
     * <p>
     * FAILED : Failed transaction block (queries will be rejected until block is ended)
     */
    override void handleReadyForQuery(TxStatus txStatus) {
        CommandResponse!(R) resp;
        if (_failure !is null) {
            resp = failedResponse!(R)(_failure, txStatus);
        } else {
            resp = succeededResponse(result, txStatus);
        }

        if(completionHandler !is null) {
            // resp.cmd = cmd;
            completionHandler(resp);
        }
    }
    override void handleNoticeResponse(NoticeResponse noticeResponse) {
        if(noticeHandler !is null) {
            noticeHandler(noticeResponse);
        }
    }

    override C getCommand() {
        return cmd;
    }
}
