module hunt.database.base.impl.command.CommandResponse;

import hunt.database.base.impl.command.CommandBase;
import hunt.database.base.impl.command.CommandScheduler;

import hunt.database.base.AsyncResult;
import hunt.database.base.Common;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.TxStatus;

import hunt.logging.ConsoleLogger;
import hunt.Object;
import hunt.util.TypeUtils;

alias ResponseHandler(R) = EventHandler!(CommandResponse!(R));
// alias CommandHandler = EventHandler!(ICommandResponse);
// alias VoidResponseHandler = ResponseHandler!(Void);


interface ICommandResponse : IAsyncResult {
    TxStatus txStatus();

    void notifyCommandResponse();  

    bool isCommandAttatched();

    void attachCommand(ICommand cmd);
}

/**
 * 
 */
abstract class CommandResponse(R) : AsyncResult!(R), ICommandResponse {

    // The connection that executed the command
    CommandScheduler scheduler;
    ICommand cmd;
    private TxStatus _txStatus;

    this(TxStatus txStatus) {
        this._txStatus = txStatus;
    }

    TxStatus txStatus() {
        return _txStatus;
    }

    void notifyCommandResponse() {
        if(cmd !is null) {
            version(HUNT_DB_DEBUG_MORE) trace("response command:", typeid(cast(Object)cmd));
            cmd.notifyResponse(this);
        } else {
            version(HUNT_DB_DEBUG) warning("No command set.");
        }
    }

    bool isCommandAttatched() {
        return cmd !is null;
    }

    void attachCommand(ICommand cmd) {
        CommandBase!(R) c = cast(CommandBase!(R))cmd;
        version(HUNT_DB_DEBUG) {
            if(c is null) { 
                warningf("Can't cast cmd from %s to %s", 
                    (typeid(cast(Object)cmd)), // TypeUtils.getSimpleName
                    typeid(CommandBase!(R)));
            }
        }
        this.cmd = c;
    }

}

/**
 * 
 */
template failedResponse(R) {
    CommandResponse!(R) failedResponse(string msg) {
        return failedResponse!R(new NoStackTraceThrowable(msg), TxStatus.FAILED);
    }

    CommandResponse!(R) failedResponse(string msg, TxStatus txStatus) {
        return failedResponse!R(new NoStackTraceThrowable(msg), txStatus);
    }

    CommandResponse!(R) failedResponse(Throwable cause) {
        return failedResponse!R(cause, TxStatus.FAILED);
    }

    CommandResponse!(R) failedResponse(Throwable r, TxStatus txStatus) {
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
 * 
 */
template succeededResponse(R) {

    CommandResponse!(R) succeededResponse(R result) {
        return succeededResponse(result, TxStatus.IDLE);
    }

    CommandResponse!(R) succeededResponse(R r, TxStatus txStatus) {
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
