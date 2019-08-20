module hunt.database.postgresql.data.Interval;

import std.conv;

/**
 * Postgres Interval is date and time based
 * such as 120 years 3 months 332 days 20 hours 20 minutes 20.999999 seconds
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */

class Interval {

    private int _years, _months, _days, _hours, _minutes, _seconds, _microseconds;

    this() {
        this(0, 0, 0, 0, 0, 0, 0);
    }

    this(int years, int months, int days, int hours, int minutes, int seconds, int microseconds) {
        this._years = years;
        this._months = months;
        this._days = days;
        this._hours = hours;
        this._minutes = minutes;
        this._seconds = seconds;
        this._microseconds = microseconds;
    }

    this(int years, int months, int days, int hours, int minutes, int seconds) {
        this(years, months, days, hours, minutes, seconds, 0);
    }

    this(int years, int months, int days, int hours, int minutes) {
        this(years, months, days, hours, minutes, 0);
    }

    this(int years, int months, int days, int hours) {
        this(years, months, days, hours, 0);
    }

    this(int years, int months, int days) {
        this(years, months, days, 0);
    }

    this(int years, int months) {
        this(years, months, 0);
    }

    this(int years) {
        this(years, 0);
    }

    // this(JsonObject json) {
    //     IntervalConverter.fromJson(json, this);
    // }

    static Interval of() {
        return new Interval();
    }

    static Interval of(int years, int months, int days, int hours, int minutes, int seconds, int microseconds) {
        return new Interval(years, months, days, hours, minutes, seconds, microseconds);
    }

    static Interval of(int years, int months, int days, int hours, int minutes, int seconds) {
        return new Interval(years, months, days, hours, minutes, seconds);
    }

    static Interval of(int years, int months, int days, int hours, int minutes) {
        return new Interval(years, months, days, hours, minutes);
    }

    static Interval of(int years, int months, int days, int hours) {
        return new Interval(years, months, days, hours);
    }

    static Interval of(int years, int months, int days) {
        return new Interval(years, months, days);
    }

    static Interval of(int years, int months) {
        return new Interval(years, months);
    }

    static Interval of(int years) {
        return new Interval(years);
    }

    Interval years(int years)  {
        this._years = years;
        return this;
    }

    Interval months(int months)  {
        this._months = months;
        return this;
    }

    Interval days(int days)  {
        this._days = days;
        return this;
    }

    Interval hours(int hours)  {
        this._hours = hours;
        return this;
    }

    Interval minutes(int minutes)  {
        this._minutes = minutes;
        return this;
    }

    Interval seconds(int seconds)  {
        this._seconds = seconds;
        return this;
    }

    Interval microseconds(int microseconds)  {
        this._microseconds = microseconds;
        return this;
    }

    int getYears() {
        return _years;
    }

    void setYears(int years) {
        this._years = years;
    }

    int getMonths() {
        return _months;
    }

    void setMonths(int months) {
        this._months = months;
    }

    int getDays() {
        return _days;
    }

    void setDays(int days) {
        this._days = days;
    }

    int getHours() {
        return _hours;
    }

    void setHours(int hours) {
        this._hours = hours;
    }

    int getMinutes() {
        return _minutes;
    }

    void setMinutes(int minutes) {
        this._minutes = minutes;
    }

    int getSeconds() {
        return _seconds;
    }

    void setSeconds(int seconds) {
        this._seconds = seconds;
    }

    int getMicroseconds() {
        return _microseconds;
    }

    void setMicroseconds(int microseconds) {
        this._microseconds = microseconds;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        Interval interval = cast(Interval) o;
        if(interval is null) return false;
        
        return _years == interval._years &&
            _months == interval._months &&
            _days == interval._days &&
            _hours == interval._hours &&
            _minutes == interval._minutes &&
            _seconds == interval._seconds &&
            _microseconds == interval._microseconds;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = _years;
        result = 31 * result + _months;
        result = 31 * result + _days;
        result = 31 * result + _hours;
        result = 31 * result + _minutes;
        result = 31 * result + _seconds;
        result = 31 * result + _microseconds;
        return result;
    }

    override
    string toString() {
        import std.format;
        import std.math : abs;
        string r = format("Interval( %d years %d months %d days %d hours %d minutes %d%s seconds )",
            _years, _months, _days, _hours, _minutes, _seconds, 
            (_microseconds == 0 ? "" : "." ~ abs(_microseconds).to!string()));
        return r;
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     IntervalConverter.toJson(this, json);
    //     return json;
    // }
}
