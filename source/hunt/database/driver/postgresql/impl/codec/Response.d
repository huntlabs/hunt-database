/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module hunt.database.driver.postgresql.impl.codec.Response;

/**
 *
 * <p>
 * A common response message for PostgreSQL
 * <a href="https://www.postgresql.org/docs/9.5/static/protocol-error-fields.html">Error and Notice Message Fields</a>
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */

abstract class Response {

    private string severity;
    private string code;
    private string message;
    private string detail;
    private string hint;
    private string position;
    private string internalPosition;
    private string internalQuery;
    private string where;
    private string file;
    private string line;
    private string routine;
    private string schema;
    private string table;
    private string column;
    private string dataType;
    private string constraint;

    string getSeverity() {
        return severity;
    }

    void setSeverity(string severity) {
        this.severity = severity;
    }

    string getCode() {
        return code;
    }

    void setCode(string code) {
        this.code = code;
    }

    string getMessage() {
        return message;
    }

    void setMessage(string message) {
        this.message = message;
    }

    string getDetail() {
        return detail;
    }

    void setDetail(string detail) {
        this.detail = detail;
    }

    string getHint() {
        return hint;
    }

    void setHint(string hint) {
        this.hint = hint;
    }

    string getPosition() {
        return position;
    }

    void setPosition(string position) {
        this.position = position;
    }

    string getWhere() {
        return where;
    }

    void setWhere(string where) {
        this.where = where;
    }

    string getFile() {
        return file;
    }

    void setFile(string file) {
        this.file = file;
    }

    string getLine() {
        return line;
    }

    void setLine(string line) {
        this.line = line;
    }

    string getRoutine() {
        return routine;
    }

    void setRoutine(string routine) {
        this.routine = routine;
    }

    string getSchema() {
        return schema;
    }

    void setSchema(string schema) {
        this.schema = schema;
    }

    string getTable() {
        return table;
    }

    void setTable(string table) {
        this.table = table;
    }

    string getColumn() {
        return column;
    }

    void setColumn(string column) {
        this.column = column;
    }

    string getDataType() {
        return dataType;
    }

    void setDataType(string dataType) {
        this.dataType = dataType;
    }

    string getConstraint() {
        return constraint;
    }

    void setConstraint(string constraint) {
        this.constraint = constraint;
    }


    string getInternalPosition() {
        return internalPosition;
    }

    void setInternalPosition(string internalPosition) {
        this.internalPosition = internalPosition;
    }

    string getInternalQuery() {
        return internalQuery;
    }

    void setInternalQuery(string internalQuery) {
        this.internalQuery = internalQuery;
    }


    override
    string toString() {
        return "Response{" ~
            "severity='" ~ severity ~ "\'" ~
            ", code='" ~ code ~ "\'" ~
            ", message='" ~ message ~ "\'" ~
            ", detail='" ~ detail ~ "\'" ~
            ", hint='" ~ hint ~ "\'" ~
            ", position='" ~ position ~ "\'" ~
            ", internalPosition='" ~ internalPosition ~ "\'" ~
            ", internalQuery='" ~ internalQuery ~ "\'" ~
            ", where='" ~ where ~ "\'" ~
            ", file='" ~ file ~ "\'" ~
            ", line='" ~ line ~ "\'" ~
            ", routine='" ~ routine ~ "\'" ~
            ", schema='" ~ schema ~ "\'" ~
            ", table='" ~ table ~ "\'" ~
            ", column='" ~ column ~ "\'" ~
            ", dataType='" ~ dataType ~ "\'" ~
            ", constraint='" ~ constraint ~ "\'" ~
            '}';
    }
}
