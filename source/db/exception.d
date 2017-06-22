module db.exception;

class DatabaseException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

class SQLException : Exception
{
	protected string _stateString;
	this(string msg, string stateString, string f = __FILE__, size_t l = __LINE__)
	{
		super(msg, f, l);
		_stateString = stateString;
	}

	this(string msg, string f = __FILE__, size_t l = __LINE__)
	{
		super(msg, f, l);
	}

	this(Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
	{
		super(causedBy.msg, causedBy, f, l);
	}

	this(string msg, Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
	{
		super(causedBy.msg, causedBy, f, l);
	}

	this(string msg, string stateString, Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
	{
		super(causedBy.msg, causedBy, f, l);
		_stateString = stateString;
	}
}
