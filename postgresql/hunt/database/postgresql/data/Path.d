module hunt.database.postgresql.data;

import io.vertx.codegen.annotations.DataObject;
import io.vertx.core.json.JsonObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Path data type in Postgres represented by lists of connected points.
 * Paths can be open, where the first and last points in the list are considered not connected,
 * or closed, where the first and last points are considered connected.
 */
@DataObject(generateConverter = true)
class Path {
  private boolean isOpen;
  private List!(Point) points;

  Path() {
    this(false, new ArrayList<>());
  }

  Path(boolean isOpen, List!(Point) points) {
    this.isOpen = isOpen;
    this.points = points;
  }


  Path(JsonObject json) {
    PathConverter.fromJson(json, this);
  }

  boolean isOpen() {
    return isOpen;
  }

  void setOpen(boolean open) {
    isOpen = open;
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
    if (o is null || getClass() != o.getClass()) return false;

    Path path = (Path) o;

    if (isOpen != path.isOpen) return false;
    return points == path.points;
  }

  override
  size_t toHash() @trusted nothrow {
    int result = (isOpen ? 1 : 0);
    result = 31 * result + points.hashCode();
    return result;
  }

  override
  String toString() {
    String left;
    String right;
    if (isOpen) {
      left = "[";
      right = "]";
    } else {
      left = "(";
      right = ")";
    }
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("Path");
    stringBuilder.append(left);
    for (int i = 0; i < points.size(); i++) {
      Point point = points.get(i);
      stringBuilder.append(point.toString());
      if (i != points.size() - 1) {
        // not the last one
        stringBuilder.append(",");
      }
    }
    stringBuilder.append(right);
    return stringBuilder.toString();
  }

  JsonObject toJson() {
    JsonObject json = new JsonObject();
    PathConverter.toJson(this, json);
    return json;
  }
}
