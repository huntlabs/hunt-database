module hunt.database.base.Annotations;

//@ColumnName
struct Column {
    string name;
    int index = -1;
    bool nullable = true;
}