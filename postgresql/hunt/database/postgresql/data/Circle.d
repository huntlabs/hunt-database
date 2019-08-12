module hunt.database.postgresql.data;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

/**
 * Circle data type in Postgres represented by a center {@link Point} and radius.
 */
@DataObject(generateConverter = true)
class Circle {
  private Point centerPoint;
  private double radius;

  Circle() {
    this(new Point(), 0.0);
  }

  Circle(Point centerPoint, double radius) {
    this.centerPoint = centerPoint;
    this.radius = radius;
  }

  Circle(JsonObject json) {
    CircleConverter.fromJson(json, this);
  }

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
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Circle that = (Circle) o;

    if (radius != that.radius) return false;
    if (!centerPoint == that.centerPoint) return false;

    return true;
  }

  override
  size_t toHash() @trusted nothrow {
    int result;
    long temp;
    result = centerPoint.hashCode();
    temp = Double.doubleToLongBits(radius);
    result = 31 * result + (int) (temp ^ (temp >>> 32));
    return result;
  }

  override
  String toString() {
    return "Circle<" + centerPoint.toString() + "," + radius + ">";
  }

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    CircleConverter.toJson(this, json);
    return json;
  }
}
