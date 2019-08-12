module hunt.database.postgresql.data;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

/**
 * Rectangular box data type in Postgres represented by pairs of {@link Point}s that are opposite corners of the box.
 */
@DataObject(generateConverter = true)
class Box {
  private Point upperRightCorner, lowerLeftCorner;

  Box() {
    this(new Point(), new Point());
  }

  Box(Point upperRightCorner, Point lowerLeftCorner) {
    this.upperRightCorner = upperRightCorner;
    this.lowerLeftCorner = lowerLeftCorner;
  }

  Box(JsonObject json) {
    BoxConverter.fromJson(json, this);
  }

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

  override
  bool opEquals(Object o) {
    if (this == o) return true;
    if (o is null || getClass() != o.getClass()) return false;

    Box box = (Box) o;

    if (!upperRightCorner == box.upperRightCorner) return false;
    if (!lowerLeftCorner == box.lowerLeftCorner) return false;

    return true;
  }

  override
  size_t toHash() @trusted nothrow {
    int result = upperRightCorner.hashCode();
    result = 31 * result + lowerLeftCorner.hashCode();
    return result;
  }

  override
  String toString() {
    return "Box(" ~ upperRightCorner.toString() ~ "," ~ lowerLeftCorner.toString() ~ ")";
  }

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    BoxConverter.toJson(this, json);
    return json;
  }
}
