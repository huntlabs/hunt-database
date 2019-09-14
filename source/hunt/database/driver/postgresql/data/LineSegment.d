module hunt.database.driver.postgresql.data.LineSegment;

import hunt.database.driver.postgresql.data.Point;

/**
 * Finite line segment data type in Postgres represented by pairs of {@link Point}s that are the endpoints of the segment.
 */
class LineSegment {
    private Point p1, p2;

    this() {
        this(new Point(), new Point());
    }

    this(Point p1, Point p2) {
        this.p1 = p1;
        this.p2 = p2;
    }

    // this(JsonObject json) {
    //     LineSegmentConverter.fromJson(json, this);
    // }

    Point getP1() {
        return p1;
    }

    void setP1(Point p1) {
        this.p1 = p1;
    }

    Point getP2() {
        return p2;
    }

    void setP2(Point p2) {
        this.p2 = p2;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;

        LineSegment that = cast(LineSegment) o;
        if (that is null)
            return false;

        if (p1 != that.p1)
            return false;
        if (p2 != that.p2)
            return false;

        return true;
    }

    override size_t toHash() @trusted nothrow {
        size_t result = p1.toHash();
        result = 31 * result + p2.toHash();
        return result;
    }

    override string toString() {
        return "LineSegment[" ~ p1.toString() ~ "," ~ p2.toString() ~ "]";
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     LineSegmentConverter.toJson(this, json);
    //     return json;
    // }
}
