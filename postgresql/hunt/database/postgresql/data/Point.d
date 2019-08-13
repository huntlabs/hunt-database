/*
 * Copyright (C) 2018 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
module hunt.database.postgresql.data.Point;

import std.conv;

/**
 * A Postgresql point.
 */
class Point {

    private double x, y;

    this() {
        this(0, 0);
    }

    this(double x, double y) {
        this.x = x;
        this.y = y;
    }

    // this(JsonObject json) {
    //     PointConverter.fromJson(json, this);
    // }

    double getX() {
        return x;
    }

    Point setX(double x) {
        this.x = x;
        return this;
    }

    double getY() {
        return y;
    }

    Point setY(double y) {
        this.y = y;
        return this;
    }

    override bool opEquals(Object obj) {
        if (this is obj)
            return true;
        Point that = cast(Point) obj;
        if (that is null)
            return false;
        return x == that.x && y == that.y;
    }

    override string toString() {
        return "this(" ~ x.to!string() ~ "," ~ y.to!string() ~ ")";
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     PointConverter.toJson(this, json);
    //     return json;
    // }
}
