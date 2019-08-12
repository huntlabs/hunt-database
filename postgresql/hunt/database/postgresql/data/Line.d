module hunt.database.postgresql.data;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

/**
 * Line data type in Postgres represented by the linear equation Ax + By + C = 0, where A and B are not both zero.
 */
@DataObject(generateConverter = true)
class Line {
  private double a;
  private double b;
  private double c;

  Line() {
    this(0.0, 0.0, 0.0);
  }

  Line(double a, double b, double c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }

  Line(JsonObject json) {
    LineConverter.fromJson(json, this);
  }

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
    if (this == o) return true;
    if (o is null || getClass() != o.getClass()) return false;

    Line that = (Line) o;

    if (a != that.a) return false;
    if (b != that.b) return false;
    if (c != that.c) return false;

    return true;
  }

  override
  size_t toHash() @trusted nothrow {
    int result;
    long temp;
    temp = Double.doubleToLongBits(a);
    result = (int) (temp ^ (temp >>> 32));
    temp = Double.doubleToLongBits(b);
    result = 31 * result + (int) (temp ^ (temp >>> 32));
    temp = Double.doubleToLongBits(c);
    result = 31 * result + (int) (temp ^ (temp >>> 32));
    return result;
  }

  override
  String toString() {
    return "Line{" ~ a ~ "," ~ b ~ "," ~ c ~ "}";
  }

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    LineConverter.toJson(this, json);
    return json;
  }
}
