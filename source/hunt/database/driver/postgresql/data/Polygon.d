module hunt.database.driver.postgresql.data.Polygon;

import hunt.database.driver.postgresql.data.Point;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.text.StringBuilder;

/**
 * Polygon data type in Postgres represented by lists of points (the vertexes of the polygon).
 * Polygons are very similar to closed paths, but are stored differently and have their own set of support routines.
 */
class Polygon {
    private List!(Point) points;

    this() {
        this(new ArrayList!(Point)());
    }

    this(List!(Point) points) {
        this.points = points;
    }

    // this(JsonObject json) {
    //     PolygonConverter.fromJson(json, this);
    // }

    List!(Point) getPoints() {
        return points;
    }

    void setPoints(List!(Point) points) {
        this.points = points;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;
        Polygon polygon = cast(Polygon) o;
        if (polygon is null)
            return false;

        return points == polygon.points;
    }

    override size_t toHash() @trusted nothrow {
        return points.toHash();
    }

    override string toString() {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("Polygon");
        stringBuilder.append("(");
        for (int i = 0; i < points.size(); i++) {
            Point point = points.get(i);
            stringBuilder.append(point.toString());
            if (i != points.size() - 1) {
                // not the last one
                stringBuilder.append(",");
            }
        }
        stringBuilder.append(")");
        return stringBuilder.toString();
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     PolygonConverter.toJson(this, json);
    //     return json;
    // }
}
