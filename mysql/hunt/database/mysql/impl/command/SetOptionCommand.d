module hunt.database.mysql.impl.command.SetOptionCommand;

import hunt.database.base.impl.command.CommandBase;

import hunt.database.mysql.MySQLSetOption;
import hunt.Object;

class SetOptionCommand : CommandBase!(Void) {
    private MySQLSetOption mySQLSetOption;

    this(MySQLSetOption mySQLSetOption) {
        this.mySQLSetOption = mySQLSetOption;
    }

    MySQLSetOption option() {
        return mySQLSetOption;
    }
}
