module hunt.database.mysql.impl.command.ChangeUserCommand;

import hunt.database.mysql.impl.MySQLCollation;
import hunt.database.base.impl.command.CommandBase;

import hunt.collection.Map;

class ChangeUserCommand : CommandBase!(Void) {
  private final String username;
  private final String password;
  private final String database;
  private final MySQLCollation collation;
  private final Map!(String, String) connectionAttributes;

  ChangeUserCommand(String username, String password, String database, MySQLCollation collation, Map!(String, String) connectionAttributes) {
    this.username = username;
    this.password = password;
    this.database = database;
    this.collation = collation;
    this.connectionAttributes = connectionAttributes;
  }

  String username() {
    return username;
  }

  String password() {
    return password;
  }

  String database() {
    return database;
  }

  MySQLCollation collation() {
    return collation;
  }

  Map!(String, String) connectionAttributes() {
    return connectionAttributes;
  }
}
