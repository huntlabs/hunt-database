module hunt.database.base.impl.NamedQueryDesc;

import hunt.database.base.Exceptions;

import std.conv;
import std.string;
import std.array;
import std.conv;

/**
 * 
 */
abstract class AbstractNamedQueryDesc {

    protected int[][string] indexSet;

	protected string namedSql;

	protected string sql;

	protected int _size;

    this(string sql) {
		this.namedSql = sql;
		this.sql = sql;
    }

	int[][string] getIndexSet() {
		return indexSet;
	}

	string getNamedSql() {
		return namedSql;
	}

	string getSql() {
		return sql;
	}

	int getSize() {
		return _size;
	}
}

/**
 * See_Also:
 *  https://github.com/bnewport/Samples/blob/master/wxsutils/src/main/java/com/devwebsphere/jdbc/loader/NamedParameterStatement.java
 */
class NamedQueryDesc(string symbol, bool hasNumber) : AbstractNamedQueryDesc {

	/**
	 * Set of characters that qualify as comment or quotes starting characters.
	 */
	private enum string[] START_SKIP = ["'", "\"", "--", "/*"];

	/**
	 * Set of characters that at are the corresponding comment or quotes ending
	 * characters.
	 */
	private enum string[] STOP_SKIP = ["'", "\"", "\n", "*/"];

    
	this(string namedSql) {
        super(namedSql);
        parse(namedSql);
    }

	private void parse(string namedSql) {

		string statement = namedSql;
		int nbParameter = 1;

		size_t i = 0;
		while (i < statement.length) {
			size_t skipToPosition = i;
			while (i < statement.length) {
				skipToPosition = skipCommentsAndQuotes(statement, i);
				if (i == skipToPosition) {
					break;
				} else {
					i = skipToPosition;
				}
			}
			if (i >= statement.length) {
				break;
			}
			char c = statement[i];

			if (c == ':' || c == '&') {
				size_t j = i + 1;
				if (j < statement.length && statement[j] == ':' && c == ':') {
					// Postgres-style "::" casting operator should be skipped
					i = i + 2;
					continue;
				}

				if (j < statement.length && c == ':' && statement[j] == '{') {
					// :{x} style parameter
					while (j < statement.length && !('}' == statement[j])) {
						j++;
						if (':' == statement[j] || '{' == statement[j]) {
							throw new DatabaseException("Parameter name contains invalid character '" ~ statement[j]
									~ "' at position " ~ i.to!string() ~ " in statement: " ~ namedSql);
						}
					}
					if (j >= statement.length) {
						throw new DatabaseException("Non-terminated named parameter declaration at position " ~ i.to!string()
								~ " in statement: " ~ namedSql);
					}
					if (j - i > 3) {
						string parameter = namedSql[i + 2 .. j];

                        if(hasNumber)
						    sql = sql.replaceFirst(":" ~ parameter, symbol ~ nbParameter.to!(string));
                        else
						    sql = sql.replaceFirst(":" ~ parameter, symbol);
                        indexSet[parameter] ~= nbParameter;
						nbParameter = nbParameter + 1;
					}
					j++;
				} else {
					while (j < statement.length && !isParameterSeparator(statement[j])) {
						j++;
					}
					if (j - i > 1) {
						string parameter = namedSql[i + 1 .. j];
                        if(hasNumber)
						    sql = sql.replaceFirst(":" ~ parameter, symbol ~ nbParameter.to!(string));
                        else
						    sql = sql.replaceFirst(":" ~ parameter, symbol);

                        indexSet[parameter] ~= nbParameter;
						nbParameter = nbParameter + 1;
					}
				}
				i = j - 1;
			}
			i++;

			_size = nbParameter-1;
		}
	}

	/**
	 * Skip over comments and quoted names present in an SQL statement
	 * 
	 * @param statement
	 *            character array containing SQL statement
	 * @param position
	 *            current position of statement
	 * @return next position to process after any comments or quotes are skipped
	 */
	private static size_t skipCommentsAndQuotes(string statement, size_t position) {
		for (size_t i = 0; i < START_SKIP.length; i++) {
			if (statement[position] == START_SKIP[i][0]) {
				bool match = true;
				for (size_t j = 1; j < START_SKIP[i].length; j++) {
					if (!(statement[position + j] == START_SKIP[i][j])) {
						match = false;
						break;
					}
				}
				if (match) {
					size_t offset = START_SKIP[i].length;
					for (size_t m = position + offset; m < statement.length; m++) {
						if (statement[m] == STOP_SKIP[i][0]) {
							bool endMatch = true;
							size_t endPos = m;
							for (size_t n = 1; n < STOP_SKIP[i].length; n++) {
								if (m + n >= statement.length) {
									// last comment not closed properly
									return statement.length;
								}
								if (!(statement[m + n] == STOP_SKIP[i][n])) {
									endMatch = false;
									break;
								}
								endPos = m + n;
							}
							if (endMatch) {
								// found character sequence ending comment or
								// quote
								return endPos + 1;
							}
						}
					}
					// character sequence ending comment or quote not found
					return statement.length;
				}

			}
		}
		return position;
	}

	private enum char[] PARAMETER_SEPARATORS = ['"', '\'', ':', '&', ',', ';', '(', ')', '|', '=',
			'+', '-', '*', '%', '/', '\\', '<', '>', '^'];

	private static bool isParameterSeparator(char c) {
        import std.ascii;
		if (isWhite(c)) {
			return true;
		}
		foreach (char separator; PARAMETER_SEPARATORS) {
			if (c == separator) {
				return true;
			}
		}
		return false;
	}
}