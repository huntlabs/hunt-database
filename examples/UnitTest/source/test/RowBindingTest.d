module test.RowBindingTest;

import hunt.database;
import hunt.database.base;
import hunt.database.base.Annotations;

import hunt.util.UnitTest;

import std.conv;
import std.format;
import std.range;
import std.stdio;


class RowBindingTest {

    string sql;
    int result;
    Statement statement;
    RowSet rs;

    Database db;

    this() {
        
        db = new Database(
                "postgresql://postgres:123456@10.1.11.44:5432/postgres?charset=utf-8");
    }

    @Before
    void setUp() {

    }

    @After
    void dispose() {
        db.close();
    }

    // @Test
    // void simpleStructTest() {
    
    //     statement = db.prepare("SELECT * FROM public.test limit 10");
    //     rs = statement.query();

    //     TestEntity[] testEntities = rs.bind!TestEntity();

    //     foreach (TestEntity t; testEntities) {
    //         writeln(t);
    //     }
    //     // TestEntity(1, "{escaped}")
    //     assert(testEntities.length > 0);
    //     assert(testEntities[0].id == 1);    
    // }

    @Test
    void testClassWithColumn() {
        statement = db.prepare("SELECT * FROM test limit 10");
        rs = statement.query();

        ClassEntity[] testEntities = rs.bind!ClassEntity();

        foreach (ClassEntity t; testEntities) {
            writeln(t);
        }
        
        // id=1, value={escaped}, desc=
        assert(testEntities.length > 0); 
        assert(testEntities[0].id == 1);  
        assert(!testEntities[0].value.empty());    
    }

    @Test
    void testClassWithJoin() {

        sql = `SELECT a.id as immutable__as__id, a.message as immutable__as__message, 
        b.id as world__as__id, b.randomnumber as world__as__randomnumber 
        FROM immutable as a LEFT JOIN world as b on a.id = b.id where a.id=1;`;

        statement = db.prepare(sql);
        rs = statement.query();

        // Immutable[] testEntities = rs.bind!(Immutable, true, (a, b) => a ~ "__as__" ~ b)(); // bug
        Immutable[] testEntities = rs.bind!(Immutable, true, `a ~ "__as__" ~ b`)();

        foreach (Immutable t; testEntities) {
            writeln(t);
        }
        // id=1, message=fortune: No such file or directory, world={id=0, randomnumber=3847}
        assert(testEntities.length > 0);
        assert(testEntities[0].world !is null);  
        assert(testEntities[0].world.id == 0);  
    }  
}



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

alias DbIgnor = hunt.database.base.Annotations.Ignore;

@Table("world")
class World {
    
    @DbIgnor("Repeated column")
    int id;

    string randomnumber;
    // int randomnumber;
    // float randomnumber;

    override string toString() {
        return format("id=%d, randomnumber=%s", id, randomnumber);
    }
}