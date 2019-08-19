module hunt.database.base.impl.command.CommandResponse;

import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandScheduler;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.TxStatus;

alias ResponseHandler(R) = EventHandler!(CommandResponse!(R));

abstract class CommandResponse(R) : AsyncResult!(R) {

    // The connection that executed the command
    CommandScheduler scheduler;
    CommandBase!(R) cmd;
    private TxStatus _txStatus;

    this(TxStatus txStatus) {
        this._txStatus = txStatus;
    }

    TxStatus txStatus() {
        return _txStatus;
    }
}

template failure(R) {
    CommandResponse!(R) failure(string msg) {
        return failure(new NoStackTraceThrowable(msg), null);
    }

    CommandResponse!(R) failure(string msg, TxStatus txStatus) {
        return failure(new NoStackTraceThrowable(msg), txStatus);
    }

    CommandResponse!(R) failure(Throwable cause) {
        return failure(cause, null);
    }

    CommandResponse!(R) failure(Throwable cause, TxStatus txStatus) {
        return new class CommandResponse!(R) {
            this() {
                super(_txStatus);
            }

            override R result() {
                return R.init;
            }

            override Throwable cause() {
                return cause;
            }

            override bool succeeded() {
                return false;
            }

            override bool failed() {
                return true;
            }
        };
    }
}

/**
*/
template success(R) {

    CommandResponse!(R) success(R result) {
        return success(result, null);
    }

    CommandResponse!(R) success(R result, TxStatus txStatus) {
        return new class CommandResponse!(R) {
            this() {
                super(txStatus);
            }

            override R result() {
                return result;
            }

            override Throwable cause() {
                return null;
            }

            override bool succeeded() {
                return true;
            }

            override bool failed() {
                return false;
            }
        };
    }
}
