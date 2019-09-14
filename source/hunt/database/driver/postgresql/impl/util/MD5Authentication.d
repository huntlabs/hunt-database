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

module hunt.database.driver.postgresql.impl.util.MD5Authentication;

import std.digest.md;

/**
*/
class MD5Authentication {

    static string encode(string username, string password, byte[] salt) {

        scope MD5Digest md5 = new MD5Digest();

        md5.put(cast(ubyte[])password);
        md5.put(cast(ubyte[])username);

        string str = toHexString!(LetterCase.lower)(md5.finish());
        md5.put(cast(ubyte[])str);
        md5.put(cast(ubyte[])salt);

        return "md5" ~ toHexString!(LetterCase.lower)(md5.finish());
    }

    unittest {
        string v = encode("postgres", "123456", cast(byte[])[0x3b, 0xd3, 0x50, 0x01]);
        assert(v == "md54b6f61eb0d581191ced4adbe41458d05");
    }

}
