module hunt.database.Pool;

import core.sync.mutex;
import hunt.collection;
import hunt.util.Common;
import hunt.logging;

class Pool(T : Closeable)
{
    alias ObjectFactory = T delegate();
    private Mutex _mutex;
    private int _minSize;
    private int _maxSize;
    private ObjectFactory _objectFactory;
    private LinkedList!T _list;

    this(int minSize,int maxSize, ObjectFactory fac)
    {
        _mutex = new Mutex();
        _minSize = minSize;
        _maxSize = maxSize;
        _objectFactory = fac;
        _list = new LinkedList!(T)();
        init();
    }

    private void init()
    {
        for(int i = 0 ; i < _minSize ; i++)
        {
            _list.add(_objectFactory());
        }
    }

    T invoke()
    {
        _mutex.lock();
        scope (exit)
            _mutex.unlock();

        if (_list.size > 0)
        {
            return _list.pollFirst();
        }
        else
        {
            return _objectFactory();
        }
    }

    void revoke(T t)
    {
        // logDebug(" revoke object : ",(cast(Object)t).toHash);
        _mutex.lock();
        scope (exit)
            _mutex.unlock();

        if (_list.size < _maxSize)
            _list.add(t);
        else
            t.close();
    }

    int size()
    {
        _mutex.lock();
        scope (exit)
            _mutex.unlock();
        return _list.size;
    }

    void close()
    {
        while (_list.size > 0)
        {
            auto t = _list.pollFirst();
            t.close();
        }
    }

}

unittest
{
    import std.stdio;
    import std.random;
    import core.thread;

    class DBConnect : Closeable
    {
        void close()
        {
            writeln("db close");
        }

        void doJob()
        {
            writeln("do something");
            Thread.sleep(dur!("msecs")(uniform(1, 5)));
        }
    }

    DBConnect createDBConnect()
    {
        return new DBConnect();
    }

    Pool!DBConnect pool = new Pool!DBConnect(1,5, &createDBConnect);

    auto group = new ThreadGroup();
    foreach (_; 0 .. 9)
    {
        group.create(() { 
                auto t = pool.invoke();
                scope(exit) pool.revoke(t); 
                t.doJob();
            });
    }
    group.joinAll();

    writeln("pool size : ",pool.size);

    pool.close();

    writeln("after close ,pool size : ",pool.size);

}
