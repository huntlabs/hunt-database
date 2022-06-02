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
    SqlConnection conn = db.getConnection();


    // // 
    // writeln("============= Delete ==================");
    // sql = `DELETE From public.test where id=1;`;
    // result = db.execute(sql);
    // tracef("result: %d", result);

    // // 
    // writeln("============= Insert ==================");

    // sql = `INSERT INTO public.test(id, val) VALUES (1, 1);`;
    // result = db.execute(sql);
    // tracef("result: %d", result);

    // // 
    // writeln("============= Update ==================");
    // DateTime dt = cast(DateTime) Clock.currTime;
    // statement = db.prepare("Update test SET val = :val where id=:id");
    // statement.setParameter("id", 1);
    // // statement.setParameter("val", dt.toISOExtString());
    // statement.setParameter("val", "{$escaped}");
    // result = statement.execute();
    // tracef("result: %d", result);

    //
    writeln("============= Select ==================");
    statement = db.prepare(conn, "SELECT * FROM public.test where id=:id limit 10");
    statement.setParameter("id", 1);
    rs = statement.query();

    foreach (Row row; rs) {
        writeln(row);
    }


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


    // 
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