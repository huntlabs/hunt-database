module hunt.database.driver.mysql.impl.command.InitDbCommand;

import hunt.database.base.impl.command.CommandBase;
import hunt.Object;

class InitDbCommand : CommandBase!(Void) {
    private string _schemaName;

    this(string schemaName) {
        this._schemaName = schemaName;
    }

    string schemaName() {
        return _schemaName;
    }
}
