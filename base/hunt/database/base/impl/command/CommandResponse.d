module hunt.database.base.impl.command.CommandResponse;

import hunt.database.base.impl.TxStatus;
import io.vertx.core.AsyncResult;
import io.vertx.core.impl.NoStackTraceThrowable;

abstract class CommandResponse!(R) implements AsyncResult!(R) {

  static <R> CommandResponse!(R) failure(String msg) {
    return failure(new NoStackTraceThrowable(msg), null);
  }

  static <R> CommandResponse!(R) failure(String msg, TxStatus txStatus) {
    return failure(new NoStackTraceThrowable(msg), txStatus);
  }

  static <R> CommandResponse!(R) failure(Throwable cause) {
    return failure(cause, null);
  }

  static <R> CommandResponse!(R) failure(Throwable cause, TxStatus txStatus) {
    return new CommandResponse!(R)(txStatus) {
      override
      R result() {
        return null;
      }
      override
      Throwable cause() {
        return cause;
      }
      override
      boolean succeeded() {
        return false;
      }
      override
      boolean failed() {
        return true;
      }
    };
  }

  static <R> CommandResponse!(R) success(R result) {
    return success(result, null);
  }

  static <R> CommandResponse!(R) success(R result, TxStatus txStatus) {
    return new CommandResponse!(R)(txStatus) {
      override
      R result() {
        return result;
      }
      override
      Throwable cause() {
        return null;
      }
      override
      boolean succeeded() {
        return true;
      }
      override
      boolean failed() {
        return false;
      }
    };
  }

  // The connection that executed the command
  CommandScheduler scheduler;
  CommandBase!(R) cmd;
  private final TxStatus txStatus;

  CommandResponse(TxStatus txStatus) {
    this.txStatus = txStatus;
  }

  TxStatus txStatus() {
    return txStatus;
  }

}
