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
module hunt.database.postgresql.impl.codec.PrepareStatementCommandCodec;

import hunt.database.postgresql.impl.codec.ErrorResponse;
import hunt.database.postgresql.impl.codec.PgCommandCodec;
import hunt.database.postgresql.impl.codec.PgEncoder;
import hunt.database.postgresql.impl.codec.PgParamDesc;
import hunt.database.postgresql.impl.codec.PgRowDesc;


import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command.PrepareStatementCommand;
import hunt.database.base.impl.PreparedStatement;

class PrepareStatementCommandCodec : PgCommandCodec!(PreparedStatement, PrepareStatementCommand) {

    private PgParamDesc parameterDesc;
    private PgRowDesc rowDesc;

    this(PrepareStatementCommand cmd) {
        super(cmd);
    }

    override
    void encode(PgEncoder encoder) {
        encoder.writeParse(new Parse(cmd.sql(), cmd.statement()));
        encoder.writeDescribe(new Describe(cmd.statement(), null));
        encoder.writeSync();
    }

    override
    void handleParseComplete() {
        // Response to parse
    }

    override
    void handleParameterDescription(PgParamDesc paramDesc) {
        // Response to Describe
        this.parameterDesc = paramDesc;
    }

    override
    void handleRowDescription(PgRowDesc rowDesc) {
        // Response to Describe
        this.rowDesc = rowDesc;
    }

    override
    void handleNoData() {
        // Response to Describe
    }

    override
    void handleErrorResponse(ErrorResponse errorResponse) {
        failure = errorResponse.toException();
    }

    override
    void handleReadyForQuery(TxStatus txStatus) {
        result = new PgPreparedStatement(cmd.sql(), cmd.statement(), this.parameterDesc, this.rowDesc);
        super.handleReadyForQuery(txStatus);
    }
}
