module hunt.database.postgresql.data.Box;

import hunt.database.postgresql.data.Point;

/**
 * Rectangular box data type in Postgres represented by pairs of {@link Point}s that are opposite corners of the box.
 */
class Box {
    private Point upperRightCorner, lowerLeftCorner;

    this() {
        this(new Point(), new Point());
    }

    this(Point upperRightCorner, Point lowerLeftCorner) {
        this.upperRightCorner = upperRightCorner;
        this.lowerLeftCorner = lowerLeftCorner;
    }

    // this(JsonObject json) {
    //     BoxConverter.fromJson(json, this);
    // }

    Point getUpperRightCorner() {
        return upperRightCorner;
    }

    void setUpperRightCorner(Point upperRightCorner) {
        this.upperRightCorner = upperRightCorner;
    }

    Point getLowerLeftCorner() {
        return lowerLeftCorner;
    }

    void setLowerLeftCorner(Point lowerLeftCorner) {
        this.lowerLeftCorner = lowerLeftCorner;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;
        if (o is null)
            return false;

        Box box = cast(Box) o;
        if (box is null)
            return false;

        if (upperRightCorner != box.upperRightCorner)
            return false;
        if (lowerLeftCorner != box.lowerLeftCorner)
            return false;

        return true;
    }

    override size_t toHash() @trusted nothrow {
        size_t result = upperRightCorner.toHash();
        result = 31 * result + lowerLeftCorner.toHash();
        return result;
    }

    override string toString() {
        return "Box(" ~ upperRightCorner.toString() ~ "," ~ lowerLeftCorner.toString() ~ ")";
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     BoxConverter.toJson(this, json);
    //     return json;
    // }
}
