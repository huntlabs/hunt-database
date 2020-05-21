/*
 * Copyright (c) 2004, PostgreSQL Global Development Group
 * See the LICENSE file in the project root for more information.
 */
// Copyright (c) 2004, Open Cloud Limited.


module hunt.database.driver.postgresql.PgUtil;

import hunt.database.base.Exceptions;
import hunt.Exceptions;
import hunt.util.Appendable;
import hunt.util.Common;
import hunt.util.StringBuilder;

/**
 * Collection of utilities used by the protocol-level code.
 * 
 * Ported from org.postgresql.core.Utils
 */
class PgUtil {

    static string escapeWithQuotes(string value) {
        scope StringBuilder sb = new StringBuilder((cast(int)value.length + 10) / 10 * 11); // Add 10% for escaping.
        sb.append('\'') ;
        escapeLiteral(sb, value, false);
        sb.append('\'') ;

        return sb.toString();
    }

    /**
     * Escape the given literal <tt>value</tt> and append it to the string builder <tt>sbuf</tt>. If
     * <tt>sbuf</tt> is <tt>null</tt>, a new StringBuilder will be returned. The argument
     * <tt>standardConformingStrings</tt> defines whether the backend expects standard-conforming
     * string literals or allows backslash escape sequences.
     *
     * @param sbuf the string builder to append to; or <tt>null</tt>
     * @param value the string value
     * @param standardConformingStrings if standard conforming strings should be used
     * @return the sbuf argument; or a new string builder for sbuf is null
     * @throws SQLException if the string contains a <tt>\0</tt> character
     */
    static StringBuilder escapeLiteral(StringBuilder sbuf, string value, bool standardConformingStrings) {
        if (sbuf is null) {
            sbuf = new StringBuilder((cast(int)value.length + 10) / 10 * 11); // Add 10% for escaping.
        }
        doAppendEscapedLiteral(sbuf, value, standardConformingStrings);
        return sbuf;
    }

    /**
     * Common part for {@link #escapeLiteral(StringBuilder, string, bool)}.
     *
     * @param sbuf Either StringBuffer or StringBuilder as we do not expect any IOException to be
     *        thrown
     * @param value value to append
     * @param standardConformingStrings if standard conforming strings should be used
     */
    private static void doAppendEscapedLiteral(Appendable sbuf, string value,
            bool standardConformingStrings) {
        try {
            if (standardConformingStrings) {
                // With standard_conforming_strings on, escape only single-quotes.
                for (size_t i = 0; i < value.length; ++i) {
                    char ch = value[i];
                    if (ch == '\0') {
                        throw new DatabaseException("Zero bytes may not occur in string parameters.");
                    }
                    if (ch == '\'') {
                        sbuf.append('\'');
                    }
                    sbuf.append(ch);
                }
            } else {
                // With standard_conforming_string off, escape backslashes and
                // single-quotes, but still escape single-quotes by doubling, to
                // avoid a security hazard if the reported value of
                // standard_conforming_strings is incorrect, or an error if
                // backslash_quote is off.
                for (size_t i = 0; i < value.length; ++i) {
                    char ch = value[i];
                    if (ch == '\0') {
                        throw new DatabaseException("Zero bytes may not occur in string parameters.");
                    }
                    if (ch == '\\' || ch == '\'') {
                        sbuf.append(ch);
                    }
                    sbuf.append(ch);
                }
            }
        } catch (IOException e) {
            throw new DatabaseException("No IOException expected from StringBuffer or StringBuilder", e);
        }
    }

    /**
     * Escape the given identifier <tt>value</tt> and append it to the string builder <tt>sbuf</tt>.
     * If <tt>sbuf</tt> is <tt>null</tt>, a new StringBuilder will be returned. This method is
     * different from appendEscapedLiteral in that it includes the quoting required for the identifier
     * while {@link #escapeLiteral(StringBuilder, string, bool)} does not.
     *
     * @param sbuf the string builder to append to; or <tt>null</tt>
     * @param value the string value
     * @return the sbuf argument; or a new string builder for sbuf is null
     * @throws SQLException if the string contains a <tt>\0</tt> character
     */
    static StringBuilder escapeIdentifier(StringBuilder sbuf, string value) {
        if (sbuf is null) {
            sbuf = new StringBuilder(2 + (cast(int)value.length + 10) / 10 * 11); // Add 10% for escaping.
        }
        doAppendEscapedIdentifier(sbuf, value);
        return sbuf;
    }

    /**
     * Common part for appendEscapedIdentifier.
     *
     * @param sbuf Either StringBuffer or StringBuilder as we do not expect any IOException to be
     *        thrown.
     * @param value value to append
     */
    private static void doAppendEscapedIdentifier(Appendable sbuf, string value) {
        try {
            sbuf.append('"');

            for (size_t i = 0; i < value.length; ++i) {
                char ch = value[i];
                if (ch == '\0') {
                    throw new DatabaseException("Zero bytes may not occur in identifiers.");
                }
                if (ch == '"') {
                    sbuf.append(ch);
                }
                sbuf.append(ch);
            }

            sbuf.append('"');
        } catch (IOException e) {
            throw new DatabaseException("No IOException expected from StringBuffer or StringBuilder", e);
        }
    }

}
