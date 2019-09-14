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

module hunt.database.base.impl.command.CloseConnectionCommand;

import hunt.database.base.impl.command.CommandBase;

import hunt.Object;

import std.concurrency : initOnce;

class CloseConnectionCommand : CommandBase!(Void) {

    static CloseConnectionCommand INSTANCE() {
        __gshared CloseConnectionCommand inst;
        return initOnce!inst(new CloseConnectionCommand());
    }


    private this() {
        handler = (ar) {};
    }

}
