module hunt.database.mysql.impl.command;

import hunt.database.mysql.MySQLSetOption;
import hunt.database.base.impl.command.CommandBase;

class SetOptionCommand : CommandBase!(Void) {
  private final MySQLSetOption mySQLSetOption;

  SetOptionCommand(MySQLSetOption mySQLSetOption) {
    this.mySQLSetOption = mySQLSetOption;
  }

  MySQLSetOption option() {
    return mySQLSetOption;
  }
}
