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
module hunt.database.postgresql.impl.codec.CloseStatementCommandCodec;

import hunt.database.postgresql.impl.codec.PgCommandCodec;
import hunt.database.postgresql.impl.codec.PgEncoder;

import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.CommandResponse;

import hunt.Object;

/**
*/
class CloseStatementCommandCodec : PgCommandCodec!(Void, CloseStatementCommand) {

    this(CloseStatementCommand cmd) {
        super(cmd);
    }

    override void encode(PgEncoder encoder) {
        /*
        if (conn.psCache is null) {
            conn.writeMessage(new Close().setStatement(statement));
            conn.writeMessage(Sync.INSTANCE);
        } else {
        }
        */
        CommandResponse!(Void) resp = succeededResponse(cast(Void)null);
        if(completionHandler !is null) {
            // resp.cmd = this.cmd;
            completionHandler(resp);
        }
    }
}
