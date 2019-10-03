module hunt.database.base.Annotations;

/**
 * 
 * See_Also:
 *  https://www.objectdb.com/api/java/jpa/annotations
 */


/**
 * 
 */
struct Table {
    string name;
}

struct JoinTable {
    string name;
}

struct Column {
    string name;
    int index = -1;
    bool nullable = true;
}

struct JoinColumn {
    string name;
    string referencedColumnName;
    bool nullable = true;
}

struct InverseJoinColumn {
    string name;
    string referencedColumnName;
    bool nullable = true;
}

struct Transient {
    string reason;
}
alias Ignor = Transient;