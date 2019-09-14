module hunt.database.driver.postgresql.data.Circle;

import hunt.database.driver.postgresql.data.Point;

/**
 * Circle data type in Postgres represented by a center {@link Point} and radius.
 */
class Circle {
    private Point centerPoint;
    private double radius;

    this() {
        this(new Point(), 0.0);
    }

    this(Point centerPoint, double radius) {
        this.centerPoint = centerPoint;
        this.radius = radius;
    }

    // this(JsonObject json) {
    //     CircleConverter.fromJson(json, this);
    // }

    Point getCenterPoint() {
        return centerPoint;
    }

    void setCenterPoint(Point centerPoint) {
        this.centerPoint = centerPoint;
    }

    double getRadius() {
        return radius;
    }

    void setRadius(double radius) {
        this.radius = radius;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;

        Circle that = cast(Circle) o;
        if(that is null) return false;

        if (radius != that.radius) return false;
        if (centerPoint != that.centerPoint) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        import hunt.Double;
        size_t result = centerPoint.toHash();
        size_t temp = Double.doubleToLongBits(radius);
        result = 31 * result + cast(int) (temp ^ (temp >>> 32));
        return result;
    }

    override
    string toString() {
        import std.conv;
        return "Circle<" ~ centerPoint.toString() ~ "," ~ radius.to!string() ~ ">";
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     CircleConverter.toJson(this, json);
    //     return json;
    // }
}
