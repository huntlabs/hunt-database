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

module hunt.database.base.impl.Notification;

import std.conv;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class Notification {

    private int processId;
    private string channel;
    private string payload;

    this(int processId, string channel, string payload) {
        this.processId = processId;
        this.channel = channel;
        this.payload = payload;
    }

    int getProcessId() {
        return processId;
    }

    string getChannel() {
        return channel;
    }

    string getPayload() {
        return payload;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        Notification that = cast(Notification) o;
        if (o is null || that is null) return false;
        
        return processId == that.processId &&
            channel == that.channel &&
            payload == that.payload;
    }

    override
    size_t toHash() @trusted nothrow {
        return processId.hashOf + channel.hashOf + payload.hashOf;
    }

    override
    string toString() {
        return "NotificationResponse{" ~
            "processId=" ~ processId.to!string() ~
            ", channel='" ~ channel ~ "\'" ~
            ", payload='" ~ payload ~ "\'" ~
            "}";
    }
}
