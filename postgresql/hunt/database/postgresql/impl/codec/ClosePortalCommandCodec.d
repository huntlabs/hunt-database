/*
 * Copyright (C) 2018 Julien Viet
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
module hunt.database.postgresql.impl.codec;

import hunt.database.base.impl.command.CloseCursorCommand;

class ClosePortalCommandCodec : PgCommandCodec!(Void, CloseCursorCommand) {

  ClosePortalCommandCodec(CloseCursorCommand cmd) {
    super(cmd);
  }

  override
  void encode(PgEncoder out) {
    out.writeClosePortal(cmd.id());
    out.writeSync();
  }

  override
  void handleCloseComplete() {
    // Expected
  }
}
