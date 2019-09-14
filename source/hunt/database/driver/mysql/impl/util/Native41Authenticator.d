module hunt.database.driver.mysql.impl.util.Native41Authenticator;

import hunt.text.Charset;

import hunt.Exceptions;

import std.digest.sha;

/**
 * 
 */
class Native41Authenticator {
    /**
     * Native authentication method 'mysql_native_password'
     * Calculate method: SHA1( password ) XOR SHA1( "20-bytes random data from server" <concat> SHA1( SHA1( password ) ) )
     *
     * @param password password value
     * @param charset  charset of password
     * @param salt     20 byte random challenge from server
     * @return scrambled password
     */
    static byte[] encode(string password, Charset charset, byte[] salt) {
        scope SHA1Digest messageDigest = new SHA1Digest();

        // SHA1(password)
        ubyte[] passwordHash1 = messageDigest.digest(password);
        messageDigest.reset();
        // SHA1(SHA1(password))
        ubyte[] passwordHash2 = messageDigest.digest(passwordHash1);
        messageDigest.reset();

        // SHA1("20-bytes random data from server" <concat> SHA1(SHA1(password))
        messageDigest.put(cast(ubyte[])salt);
        messageDigest.put(passwordHash2);
        ubyte[] passwordHash3 = messageDigest.finish();

        // result = passwordHash1 XOR passwordHash3
        for (int i = 0; i < cast(int)passwordHash1.length; i++) {
            passwordHash1[i] = cast(byte) (passwordHash1[i] ^ passwordHash3[i]);
        }
        return cast(byte[])passwordHash1;
    }
}
