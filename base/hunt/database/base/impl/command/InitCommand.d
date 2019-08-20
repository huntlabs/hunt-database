/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.base.impl.command.InitCommand;

import hunt.database.base.impl.command.CommandBase;

import hunt.database.base.impl.Connection;
import hunt.database.base.impl.SocketConnectionBase;

import hunt.collection.Map;

/**
 * Initialize the connection so it can be used to interact with the database.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class InitCommand : CommandBase!(Connection) {

    private SocketConnectionBase conn;
    private string _username;
    private string _password;
    private string _database;
    private Map!(string, string) _properties;

    this(SocketConnectionBase conn,
            string username,
            string password,
            string database,
            Map!(string, string) properties) {
        this.conn = conn;
        this._username = username;
        this._password = password;
        this._database = database;
        this._properties = properties;
    }

    SocketConnectionBase connection() {
        return conn;
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

    Map!(string, string) properties() {
        return _properties;
    }

}
