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

module hunt.database.postgresql.impl.codec.PasswordMessage;

import hunt.database.postgresql.impl.util.MD5Authentication;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class PasswordMessage {

  final String hash;

  PasswordMessage(String username, String password, byte[] salt) {
    this.hash = salt !is null ? MD5Authentication.encode(username, password, salt) : password;
  }
}
