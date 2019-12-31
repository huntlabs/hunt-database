module hunt.database.driver.postgresql.data.Line;

import hunt.Double;

/**
 * Line data type in Postgres represented by the linear equation Ax + By + C = 0, where A and B are not both zero.
 */
class Line {
    private double a;
    private double b;
    private double c;

    this() {
        this(0.0, 0.0, 0.0);
    }

    this(double a, double b, double c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }

    // this(JsonObject json) {
    //     LineConverter.fromJson(json, this);
    // }

    double getA() {
        return a;
    }

    void setA(double a) {
        this.a = a;
    }

    double getB() {
        return b;
    }

    void setB(double b) {
        this.b = b;
    }

    double getC() {
        return c;
    }

    void setC(double c) {
        this.c = c;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        Line that = cast(Line) o;
        if(that is null) return false;

        if (a != that.a) return false;
        if (b != that.b) return false;
        if (c != that.c) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        import hunt.Double;
        ulong result;
        ulong temp;
        temp = Double.doubleToLongBits(a);
        result = (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(b);
        result = 31 * result + (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(c);
        result = 31 * result + (temp ^ (temp >>> 32));
        return cast(size_t)result;
    }

    override
    string toString() {
        import std.conv;
        return "Line{" ~ a.to!string() ~ "," ~ b.to!string() ~ "," ~ c.to!string() ~ "}";
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     LineConverter.toJson(this, json);
    //     return json;
    // }
}
