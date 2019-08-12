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

import java.util.Objects;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class Notification {

  private final int processId;
  private final String channel;
  private final String payload;

  Notification(int processId, String channel, String payload) {
    this.processId = processId;
    this.channel = channel;
    this.payload = payload;
  }

  int getProcessId() {
    return processId;
  }

  String getChannel() {
    return channel;
  }

  String getPayload() {
    return payload;
  }

  override
  bool opEquals(Object o) {
    if (this == o) return true;
    if (o is null || getClass() != o.getClass()) return false;
    Notification that = (Notification) o;
    return processId == that.processId &&
      Objects.equals(channel, that.channel) &&
      Objects.equals(payload, that.payload);
  }

  override
  size_t toHash() @trusted nothrow {
    return Objects.hash(processId, channel, payload);
  }

  override
  String toString() {
    return "NotificationResponse{" +
      "processId=" + processId +
      ", channel='" + channel + '\'' +
      ", payload='" + payload + '\'' +
      '}';
  }
}
