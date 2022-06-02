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

import std.stdio;
import hunt.logging;
import hunt.net.EventLoopPool;
import hunt.concurrency.Future;

import hunt.database;
import std.datetime;

void main() {
    writeln("PostgreSQL demo.");
    string sql;
    int result;
    Statement statement;
    RowSet rs;

    string url = "postgresql://postgres:123456@10.1.11.44:5432/postgres?charset=utf-8";
    DatabaseOption options = new DatabaseOption(url);

    options.setConnectionTimeout(60000);

    Database db = new Database(options);

    // Database db = new Database(
    //         "postgresql://postgres:123456@10.1.11.44:5432/eql_test?charset=utf-8");


    // Database db = new Database(
    //         "postgresql://postgres:123456@10.1.223.222:5432/postgres?charset=utf-8");            

    // Database db = new Database(
    //     "postgresql://putao:putao123@10.1.223.62:5432/uas?prefix=&charset=utf8");

    // SqlConnection sqlConn = db.getConnection();
    // Transaction transcation = sqlConn.begin();

    // // // 
    // // writeln("============= Delete ==================");
    // // sql = `DELETE From public.test where id=1;`;
    // // result = db.execute(sql);
    // // tracef("result: %d", result);

    // // // 
    // // writeln("============= Insert ==================");

    // // sql = `INSERT INTO public.test(id, val) VALUES (13, 'abc');`;
    // sql = `INSERT INTO public.test(val) VALUES ('abc') RETURNING id;`;
    // // sql = `INSERT INTO public.test(val) VALUES ('abc'), ('123') RETURNING id, val;`;
    // // sql = `INSERT INTO public.test(val) VALUES ('abc');`;
    // // result = db.execute(sql);

    // tracef("transcation status: %s", transcation.status());
    // Future!RowSet promise = transcation.queryAsync(sql);
    // rs = promise.get(5.seconds);

    // tracef("Rows: \n%s", rs.toString());

    // import core.thread;
    // // Thread.sleep(20.seconds);
    
    // tracef("transcation status: %s", transcation.status());

    // // transcation.rollback();
    // // transcation.commit();

    // // tracef("transcation status: %s", transcation.status());

    // // result = db.execute(sql, "id");
    // // result = db.query(sql).columnInLastRow("id");
    // // Row row = db.query(sql).lastRow();
    // // if(row !is null) {
    // //     result = row.getInteger("id");
    // // }
    // // tracef("result: %d", result);

    // // sqlConn.close();
    // tracef("status: %s", db.poolInfo());



    // string v  = db.execute!(string)(sql, "val");
    // tracef("val: %s", v);    

    // // 
    // writeln("============= Update ==================");
    // DateTime dt = cast(DateTime) Clock.currTime;
    // statement = db.prepare("Update test SET val = :val where id=:id");
    // statement.setParameter("id", 1);
    // // statement.setParameter("val", dt.toISOExtString());
    // statement.setParameter("val", "{$escaped}");
    // result = statement.execute();
    // tracef("result: %d", result);

    // //
    // writeln("============= Select ==================");

    SqlConnection conn = db.getConnection();

    // case 1
    {
        sql = "SELECT * FROM public.test where id=:id limit 10";
        
        statement = db.prepare(conn, sql);
        statement.setParameter("id", 1);
    }

    // {
    //     sql = "SELECT * FROM userinfo where id=1";
        
    //     statement = db.prepare(conn, sql);
    //     statement.setParameter("id", 1);
    // }

    rs = statement.query();

    foreach (Row row; rs) {
        writeln(row);

        byte[] b  = row.getBuffer(3);
        warningf("%(%02X %)", b);
    }


    // warning("11111");
    // conn.close();

    // warning("xxxx");

    //
    // writeln("============= Select ==================");
    // rs = db.query("SELECT * FROM app");

    // foreach (Row row; rs) {
    //     writeln(row);
    // }

    // writeln("============= Select ==================");
    // rs = db.query("SELECT * FROM user_account");

    // foreach (Row row; rs) {
    //     writeln(row);
    // }


    // rs = db.query("SELECT email FROM user_account");

    //
    // writeln("============= Binding ==================");
    // statement = db.prepare("SELECT * FROM public.test limit 10");
    // rs = statement.query();

    // TestEntity[] testEntities = rs.bind!TestEntity();

    // foreach (TestEntity t; testEntities) {
    //     writeln(t);
    // }

    // 
    // writeln("============= Simple Binding ==================");
    // statement = db.prepare("SELECT * FROM public.test limit 10");
    // rs = statement.query();

    // TestEntity[] testEntities = rs.bind!TestEntity();

    // foreach (TestEntity t; testEntities) {
    //     writeln(t);
    // }

    // // 
    // writeln("============= Class Binding ==================");
    // statement = db.prepare("SELECT * FROM test limit 10");
    // rs = statement.query();

    // ClassEntity[] testEntities = rs.bind!ClassEntity();

    // foreach (ClassEntity t; testEntities) {
    //     writeln(t);
    // }    


    // // 
    // writeln("============= Class Binding ==================");
    // sql = `SELECT a.id as immutable__as__id, a.message as immutable__as__message, 
	// b.id as world__as__id, b.randomnumber as world__as__randomnumber 
	// FROM immutable as a LEFT JOIN world as b on a.id = b.id where a.id=1;`;

    // statement = db.prepare(sql);
    // rs = statement.query();

    // Immutable[] testEntities = rs.bind!(Immutable, (a, b) => a ~ "__as__" ~ b)();

    // foreach (Immutable t; testEntities) {
    //     writeln(t);
    // }    


    db.close();
    getchar();

    shutdownEventLoopPool();

    getchar();
}

import hunt.database.base.Annotations;

import std.conv;
import std.format;

struct TestEntity {
    int id;
    string val;
}

// Inherit
class EntityBase {
    @Column("val")
    string value;
}

class ClassEntity : EntityBase {
    int id;

    string desc;

    override string toString() {
        return format("id=%d, value=%s, desc=%s", id, value, desc);
    }
}

// Join
@Table("immutable")
class Immutable {

    int id;

    string message;

    World world;

    override string toString() {
        return format("id=%d, message=%s, world={%s}", id, message, world.to!string());
    }
}

@Table("world")
class World {
    
    @Ignore("Repeated column")
    int id;

    string randomnumber;
    // int randomnumber;
    // float randomnumber;

    override string toString() {
        return format("id=%d, randomnumber=%s", id, randomnumber);
    }
}