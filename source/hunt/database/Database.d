/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.database.Database;

import hunt.database.DatabaseOption;
import hunt.database.Statement;

import hunt.database.base;
import hunt.database.driver.mysql;
import hunt.database.driver.postgresql;
import hunt.database.query.QueryBuilder;

import hunt.logging;
import hunt.net.util.HttpURI;
import hunt.util.StringBuilder;

import core.time;

/**
 * 
 */
class Database {
    Pool _pool;
    DatabaseOption _options;

    this(string url) {
        this._options = new DatabaseOption(url);
        initPool();
    }

    this(DatabaseOption options) {
        this._options = options;
        initPool();
    }

    ~this() {
        close();
    }

    DatabaseOption getOption() {
        return _options;
    }

    Transaction getTransaction(SqlConnection conn) {
        return conn.begin();
    }

    SqlConnection getConnection() {
        return _pool.getConnection();
    }

    void closeConnection(SqlConnection conn) {
        conn.close();
    }

    void relaseConnection(SqlConnection conn) {
        conn.close();
    }

    private void initPool() {
        import hunt.database.driver.mysql.impl.MySQLPoolImpl;
        import hunt.database.driver.postgresql.impl.PostgreSQLPoolImpl;
        import core.time;

        version (HUNT_DB_DEBUG) {
            tracef("maximumSize: %d, connectionTimeout: %d, maxWaitQueueSize: %d",
                    _options.maximumPoolSize, _options.connectionTimeout, _options.maxWaitQueueSize);
        }

        // dfmt off
        PoolOptions poolOptions = new PoolOptions()
            .setMaxSize(_options.maximumPoolSize)
            .retry(_options.retry)
            .awaittingTimeout(_options.connectionTimeout.msecs)
            .setMaxWaitQueueSize(_options.maxWaitQueueSize);

        if(_options.isPgsql()) {
            PgConnectOptions connectOptions = new PgConnectOptions(_options.url);
            connectOptions.setDecoderBufferSize(_options.getDecoderBufferSize());
            connectOptions.setEncoderBufferSize(_options.getEncoderBufferSize());
            connectOptions.setConnectTimeout(_options.connectionTimeout().msecs);

            _pool = new PgPoolImpl(connectOptions, poolOptions);
        } else if(_options.isMysql()) {
            MySQLConnectOptions connectOptions = new MySQLConnectOptions(_options.url);
            connectOptions.setDecoderBufferSize(_options.getDecoderBufferSize());
            connectOptions.setEncoderBufferSize(_options.getEncoderBufferSize());
            connectOptions.setConnectTimeout(_options.connectionTimeout().msecs);

            _pool = new MySQLPoolImpl(connectOptions, poolOptions);

        } else {
            throw new DatabaseException("Unsupported database driver: " ~ _options.schemeName());
        }

        // dfmt on
    }

    /// return the count of affected rows.
    int execute(string sql) {
        RowSet rs = query(sql);
        return rs.rowCount();
    }

    RowSet query(string sql) {
        version (HUNT_SQL_DEBUG)
            info(sql);
        SqlConnection conn = getConnection();
        scope (exit) {
            conn.close();
        }

        RowSet rs = conn.query(sql);
        return rs;
    }

    Statement prepare(string sql) {
        SqlConnection conn = getConnection();
        Statement ret = new Statement(conn, sql, _options);
        return ret;
    }

    Statement prepare(SqlConnection conn, string sql) {
        Statement ret = new Statement(conn, sql, _options);
        return ret;
    }

    void close() {
        if (_pool !is null) {
            _pool.close();
            _pool = null;
        }
    }

    QueryBuilder createQueryBuilder() {
        import hunt.sql.util.DBType;

        if (_options.isPgsql()) {
            return new QueryBuilder(DBType.POSTGRESQL);
        } else if (_options.isMysql()) {
            return new QueryBuilder(DBType.MYSQL);
        } else {
            throw new DatabaseException("Unsupported database driver: " ~ _options.schemeName());
        }
    }

    string poolInfo() {
        if(_pool is null) {
            return "unset";
        } else {
            return (cast(Object)_pool).toString();
        }
    }

}
