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

module hunt.database.driver.postgresql.impl.codec.StartupMessage;

import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.Unpooled;

import hunt.collection.Map;
import hunt.text.Charset;

import std.concurrency : initOnce;

// import static java.nio.charset.StandardCharsets.UTF_8;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class StartupMessage {

    static ByteBuf BUFF_USER() {
        __gshared ByteBuf inst;
        return initOnce!inst(Unpooled.copiedBuffer("user", StandardCharsets.UTF_8).asReadOnly());
    }

    static ByteBuf BUFF_DATABASE() {
        __gshared ByteBuf inst;
        return initOnce!inst(Unpooled.copiedBuffer("database", StandardCharsets.UTF_8).asReadOnly());
    }

    string username;
    string database;
    Map!(string, string) properties;

    this(string username, string database, Map!(string, string) properties) {
        this.username = username;
        this.database = database;
        this.properties = properties;
    }
}
