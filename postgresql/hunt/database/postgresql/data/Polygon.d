module hunt.database.postgresql.data;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Polygon data type in Postgres represented by lists of points (the vertexes of the polygon).
 * Polygons are very similar to closed paths, but are stored differently and have their own set of support routines.
 */
@DataObject(generateConverter = true)
class Polygon {
  private List!(Point) points;

  Polygon() {
    this(new ArrayList<>());
  }

  Polygon(List!(Point) points) {
    this.points = points;
  }


  Polygon(JsonObject json) {
    PolygonConverter.fromJson(json, this);
  }

  List!(Point) getPoints() {
    return points;
  }

  void setPoints(List!(Point) points) {
    this.points = points;
  }

  override
  bool opEquals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Polygon polygon = (Polygon) o;

    return points == polygon.points;
  }

  override
  size_t toHash() @trusted nothrow {
    return points.hashCode();
  }

  override
  String toString() {
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

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    PolygonConverter.toJson(this, json);
    return json;
  }
}
