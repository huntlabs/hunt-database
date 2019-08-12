module hunt.database.postgresql.data.LineSegment;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

/**
 * Finite line segment data type in Postgres represented by pairs of {@link Point}s that are the endpoints of the segment.
 */
@DataObject(generateConverter = true)
class LineSegment {
  private Point p1, p2;

  LineSegment() {
    this(new Point(), new Point());
  }

  LineSegment(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
  }

  LineSegment(JsonObject json) {
    LineSegmentConverter.fromJson(json, this);
  }

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

  override
  bool opEquals(Object o) {
    if (this == o) return true;
    if (o is null || getClass() != o.getClass()) return false;

    LineSegment that = (LineSegment) o;

    if (!p1 == that.p1) return false;
    if (!p2 == that.p2) return false;

    return true;
  }

  override
  size_t toHash() @trusted nothrow {
    int result = p1.hashCode();
    result = 31 * result + p2.hashCode();
    return result;
  }

  override
  String toString() {
    return "LineSegment[" ~ p1.toString() ~ "," ~ p2.toString() ~ "]";
  }

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    LineSegmentConverter.toJson(this, json);
    return json;
  }
}
