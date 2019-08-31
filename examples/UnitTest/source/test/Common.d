module test.Common;

import hunt.database.base;
import hunt.logging.ConsoleLogger;


static T asyncAssertSuccess(T)(AsyncResult!T ar) {
    if(ar.succeeded()) {
        return ar.result();
    } else {
        warning(ar.cause().msg);
        throw new DatabaseException(ar.cause().msg);
    }
}