module hunt.database.mysql.impl.codec.ExtendedBatchQueryCommandCodec;

import hunt.database.mysql.impl.codec.ExtendedQueryCommandBaseCodec;
import hunt.database.mysql.impl.codec.MySQLEncoder;
import hunt.database.mysql.impl.codec.Packets;

import hunt.database.mysql.MySQLException;

import hunt.database.base.Exceptions;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.command.ExtendedBatchQueryCommand;
import hunt.database.base.Tuple;

import hunt.collection.List;
import hunt.net.buffer.ByteBuf;



class ExtendedBatchQueryCommandCodec(R) : ExtendedQueryCommandBaseCodec!(R, ExtendedBatchQueryCommand!(R)) {

    private List!(Tuple) params;
    private int batchIdx = 0;

    this(ExtendedBatchQueryCommand!(R) cmd) {
        super(cmd);
        params = cmd.params();
    }

    override
    void encode(MySQLEncoder encoder) {
        super.encode(encoder);
        if (params.isEmpty() && statement.paramDesc.paramDefinitions().length > 0) {
            completionHandler(failedResponse!(ICommandResponse)(
                    new DatabaseException("Statement parameter is not set because of the empty batch param list")));
            return;
        }
        doExecuteBatch();
    }

    override
    protected void handleSingleResultsetDecodingCompleted(int serverStatusFlags, int affectedRows, int lastInsertId) {
        super.handleSingleResultsetDecodingCompleted(serverStatusFlags, affectedRows, lastInsertId);
        doExecuteBatch();
    }

    override
    protected bool isDecodingCompleted(int serverStatusFlags) {
        return super.isDecodingCompleted(serverStatusFlags) && batchIdx == params.size();
    }

    private void doExecuteBatch() {
        if (batchIdx < params.size()) {
            this.sequenceId = 0;
            Tuple param = params.get(batchIdx);
            sendStatementExecuteCommand(statement.statementId, 
                statement.paramDesc.paramDefinitions(), sendType, param, cast(byte) 0x00);
            batchIdx++;
        }
    }
}
