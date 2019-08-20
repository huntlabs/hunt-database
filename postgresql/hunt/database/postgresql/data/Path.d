module hunt.database.postgresql.data.Path;

import hunt.database.postgresql.data.Point;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.text.StringBuilder;

/**
 * Path data type in Postgres represented by lists of connected points.
 * Paths can be open, where the first and last points in the list are considered not connected,
 * or closed, where the first and last points are considered connected.
 */
class Path {
    private bool _isOpen;
    private List!(Point) points;

    this() {
        this(false, new ArrayList!(Point)());
    }

    this(bool isOpen, List!(Point) points) {
        this._isOpen = isOpen;
        this.points = points;
    }

    // this(JsonObject json) {
    //     PathConverter.fromJson(json, this);
    // }

    bool isOpen() {
        return _isOpen;
    }

    void setOpen(bool open) {
        _isOpen = open;
    }

    List!(Point) getPoints() {
        return points;
    }

    void setPoints(List!(Point) points) {
        this.points = points;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;

        Path path = cast(Path) o;
        if (path is null)
            return false;

        if (_isOpen != path._isOpen)
            return false;
        return points == path.points;
    }

    override size_t toHash() @trusted nothrow {
        size_t result = (_isOpen ? 1 : 0);
        result = 31 * result + points.toHash();
        return result;
    }

    override string toString() {
        string left;
        string right;
        if (_isOpen) {
            left = "[";
            right = "]";
        } else {
            left = "(";
            right = ")";
        }
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("Path");
        stringBuilder.append(left);
        for (int i = 0; i < points.size(); i++) {
            Point point = points.get(i);
            stringBuilder.append(point.toString());
            if (i != points.size() - 1) {
                // not the last one
                stringBuilder.append(",");
            }
        }
        stringBuilder.append(right);
        return stringBuilder.toString();
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     PathConverter.toJson(this, json);
    //     return json;
    // }
}
