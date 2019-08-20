module hunt.database.base.Common;

import hunt.Object;

alias EventHandler(T) = void delegate(T t); 

alias ExceptionHandler = EventHandler!(Throwable);
alias VoidHandler = EventHandler!Void;