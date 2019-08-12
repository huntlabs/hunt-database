module hunt.database.mysql.impl.command;

import hunt.database.base.impl.command.CommandBase;

class InitDbCommand : CommandBase!(Void) {
  private final String schemaName;

  InitDbCommand(String schemaName) {
    this.schemaName = schemaName;
  }

  String schemaName() {
    return schemaName;
  }
}
