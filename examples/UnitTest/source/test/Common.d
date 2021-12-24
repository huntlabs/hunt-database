module test.Common;

import hunt.database.base;
import hunt.logging;


static T asyncAssertSuccess(T)(AsyncResult!T ar) {
    if(ar.succeeded()) {
        return ar.result();
    } else {
        warning(ar.cause().msg);
        throw new DatabaseException(ar.cause().msg);
    }
}

static Throwable asyncAssertFailure(T)(AsyncResult!T ar) {
    if(ar.failed()) {
        return ar.cause();
    } else {
        warning("Should be failed!");
        throw new DatabaseException("Should be failed!");
    }
}