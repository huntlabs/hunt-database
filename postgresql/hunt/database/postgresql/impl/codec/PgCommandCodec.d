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
module hunt.database.postgresql.impl.codec.PgCommandCodec;

import hunt.database.postgresql.impl.codec.ErrorResponse;
import hunt.database.postgresql.impl.codec.NoticeResponse;
import hunt.database.postgresql.impl.codec.PgParamDesc;
import hunt.database.postgresql.impl.codec.PgEncoder;
import hunt.database.postgresql.impl.codec.PgRowDesc;

import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.CommandBase;

import hunt.database.base.Common;

import hunt.logging.ConsoleLogger;


/**
*/
abstract class PgCommandCodecBase {

    abstract void encode(PgEncoder encoder);

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
        warning(typeid(this).name ~ " should handle message " ~ rowDescription);
    }

    void handleNoData() {
        warning(typeid(this).name ~ " should handle message NoData");
    }

    void handleNoticeResponse(NoticeResponse noticeResponse) {
        noticeHandler.handle(noticeResponse);
    }

    void handleErrorResponse(ErrorResponse errorResponse) {
        warning(typeid(this).name ~ " should handle message " ~ errorResponse);
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
}

/**
*/
abstract class PgCommandCodec(R, C) : PgCommandCodecBase
        if(is(C : CommandBase!(R))) {

    ResponseHandler!R completionHandler;
    EventHandler!(NoticeResponse) noticeHandler;
    Throwable _failure;
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
            resp = failure!(R)(_failure, txStatus);
        } else {
            resp = success(result, txStatus);
        }
        completionHandler(resp);
    }
}
