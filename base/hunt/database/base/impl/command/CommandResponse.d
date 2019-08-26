module hunt.database.base.impl.command.CommandResponse;

import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandScheduler;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.TxStatus;

alias ResponseHandler(R) = EventHandler!(CommandResponse!(R));


interface ICommandResponse {
    TxStatus txStatus();

    void notifyCommandResponse();  
}

abstract class CommandResponse(R) : AsyncResult!(R), ICommandResponse {

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

    void notifyCommandResponse() {
        if(cmd !is null) {
            cmd.notifyResponse(this);
        }
    }
}

template failure(R) {
    CommandResponse!(R) failure(string msg) {
        return failure!R(new NoStackTraceThrowable(msg), TxStatus.FAILED);
    }

    CommandResponse!(R) failure(string msg, TxStatus txStatus) {
        return failure!R(new NoStackTraceThrowable(msg), txStatus);
    }

    CommandResponse!(R) failure(Throwable cause) {
        return failure!R(cause, TxStatus.FAILED);
    }

    CommandResponse!(R) failure(Throwable r, TxStatus txStatus) {
        return new class CommandResponse!(R) {
            this() {
                super(_txStatus);
            }

            R result() {
                static if(is(R == class) || is(R == interface)) {
                    return null;
                } else {
                    return R.init;
                }
            }

            Throwable cause() {
                return r;
            }

            bool succeeded() {
                return false;
            }

            bool failed() {
                return true;
            }
        };
    }
}

/**
*/
template success(R) {

    CommandResponse!(R) success(R result) {
        return success(result, TxStatus.IDLE);
    }

    CommandResponse!(R) success(R r, TxStatus txStatus) {
        return new class CommandResponse!(R) {
            this() {
                super(txStatus);
            }

            R result() {
                return r;
            }

            Throwable cause() {
                return null;
            }

            bool succeeded() {
                return true;
            }

            bool failed() {
                return false;
            }
        };
    }
}
