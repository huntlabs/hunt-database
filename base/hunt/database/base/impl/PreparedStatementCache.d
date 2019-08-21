module hunt.database.base.impl.PreparedStatementCache;

import hunt.database.base.impl.Connection;

import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.CommandResponse;
import hunt.database.base.impl.PreparedStatement;
import hunt.database.base.impl.SocketConnectionBase;

import hunt.collection.LinkedHashMap;
import hunt.collection.Map;

import hunt.concurrency.LinkedBlockingQueue;

/**
 * A LRU replacement strategy cache based on {@link java.util.LinkedHashMap} for prepared statements.
 */
class PreparedStatementCache : LinkedHashMap!(string, CachedPreparedStatement) {
    private int capacity;
    private DbConnection conn;

    this(int capacity, DbConnection conn) {
        super(capacity, 0.75f, true);
        this.capacity = capacity;
        this.conn = conn;
    }

    override
    protected bool removeEldestEntry(MapEntry!(string, CachedPreparedStatement) eldest) {
        bool needRemove = size() > capacity;
        CachedPreparedStatement cachedPreparedStatementToRemove = eldest.getValue();

        if (needRemove) {
            if (cachedPreparedStatementToRemove.resp.succeeded()) {
                // close the statement after it has been evicted from the cache
                PreparedStatement statement = cachedPreparedStatementToRemove.resp.result();
                CloseStatementCommand cmd = new CloseStatementCommand(statement);
                cmd.handler = (ar) { };
                conn.schedule(cmd);
            }
            return true;
        }
        return false;
    }

    bool isReady() {
        MapEntry!(string, CachedPreparedStatement) entry = getEldestEntry();
        if (entry is null) {
            return true;
        } else {
            return entry.getValue().resp !is null;
        }
    }

    int getCapacity() {
        return this.capacity;
    }

    private MapEntry!(string, CachedPreparedStatement) getEldestEntry() {
        if (size() == 0) {
            return null;
        }
        return cast(MapEntry!(string, CachedPreparedStatement)) this.toArray()[size() - 1];
    }
}



class CachedPreparedStatement { // : Handler!(CommandResponse!(PreparedStatement)) 
    import std.container.dlist;
    // private Deque!(ResponseHandler!(PreparedStatement)) waiters;
    private DList!(ResponseHandler!(PreparedStatement)) waiters;
    CommandResponse!(PreparedStatement) resp;

    this() {
        // FIXME: Needing refactor or cleanup -@zxp at 8/13/2019, 6:27:09 PM
        // 
        // waiters = new ArrayDeque!(ResponseHandler!(PreparedStatement))();
        // waiters = new LinkedBlockingQueue!(ResponseHandler!(PreparedStatement))();
    }

    void get(ResponseHandler!(PreparedStatement) handler) {
        if (resp !is null) {
            handler(resp);
        } else {
            waiters.insertBack(handler);
        }
    }

    // override
    void handle(CommandResponse!(PreparedStatement) event) {
        resp = event;
        ResponseHandler!(PreparedStatement) waiter;
        while(!waiters.empty()) {
            waiter = waiters.front();
            waiter.handle(resp);
            waiters.removeFront();
        }
        // while ((waiter = waiters.poll()) !is null) {
        //     waiter.handle(resp);
        // }
    }
}