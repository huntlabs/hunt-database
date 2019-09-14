module hunt.database.driver.mysql.impl.command.ChangeUserCommand;

import hunt.database.driver.mysql.impl.MySQLCollation;
import hunt.database.base.impl.command.CommandBase;

import hunt.collection.Map;
import hunt.Object;

/**
 * 
 */
class ChangeUserCommand : CommandBase!(Void) {
    private string _username;
    private string _password;
    private string _database;
    private MySQLCollation _collation;
    private Map!(string, string) _connectionAttributes;

    this(string username, string password, string database, MySQLCollation collation, 
            Map!(string, string) connectionAttributes) {
        this._username = username;
        this._password = password;
        this._database = database;
        this._collation = collation;
        this._connectionAttributes = connectionAttributes;
    }

    string username() {
        return _username;
    }

    string password() {
        return _password;
    }

    string database() {
        return _database;
    }

    MySQLCollation collation() {
        return _collation;
    }

    Map!(string, string) connectionAttributes() {
        return _connectionAttributes;
    }
}
