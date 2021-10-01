module hunt.database.base.Common;

import hunt.Object;

import hunt.Functions;

alias EventHandler(T) = void delegate(T t); 

alias ExceptionHandler = EventHandler!(Throwable);
alias VoidHandler = Action;