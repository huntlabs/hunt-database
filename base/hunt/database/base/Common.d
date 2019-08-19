module hunt.database.base.Common;

import hunt.Object;

alias EventHandler(T) = void delegate(T t); 

alias ThrowableHandler = EventHandler!(Throwable);
alias VoidHandler = EventVoidHandler;