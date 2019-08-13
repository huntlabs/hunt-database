module hunt.database.postgresql.data.Interval;

/**
 * Postgres Interval is date and time based
 * such as 120 years 3 months 332 days 20 hours 20 minutes 20.999999 seconds
 *
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */

class Interval {

    private int years, months, days, hours, minutes, seconds, microseconds;

    this() {
        this(0, 0, 0, 0, 0, 0, 0);
    }

    this(int years, int months, int days, int hours, int minutes, int seconds, int microseconds) {
        this.years = years;
        this.months = months;
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
        this.microseconds = microseconds;
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
        this.years = years;
        return this;
    }

    Interval months(int months)  {
        this.months = months;
        return this;
    }

    Interval days(int days)  {
        this.days = days;
        return this;
    }

    Interval hours(int hours)  {
        this.hours = hours;
        return this;
    }

    Interval minutes(int minutes)  {
        this.minutes = minutes;
        return this;
    }

    Interval seconds(int seconds)  {
        this.seconds = seconds;
        return this;
    }

    Interval microseconds(int microseconds)  {
        this.microseconds = microseconds;
        return this;
    }

    int getYears() {
        return years;
    }

    void setYears(int years) {
        this.years = years;
    }

    int getMonths() {
        return months;
    }

    void setMonths(int months) {
        this.months = months;
    }

    int getDays() {
        return days;
    }

    void setDays(int days) {
        this.days = days;
    }

    int getHours() {
        return hours;
    }

    void setHours(int hours) {
        this.hours = hours;
    }

    int getMinutes() {
        return minutes;
    }

    void setMinutes(int minutes) {
        this.minutes = minutes;
    }

    int getSeconds() {
        return seconds;
    }

    void setSeconds(int seconds) {
        this.seconds = seconds;
    }

    int getMicroseconds() {
        return microseconds;
    }

    void setMicroseconds(int microseconds) {
        this.microseconds = microseconds;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        Interval interval = cast(Interval) o;
        if(interval is null) return false;
        
        return years == interval.years &&
            months == interval.months &&
            days == interval.days &&
            hours == interval.hours &&
            minutes == interval.minutes &&
            seconds == interval.seconds &&
            microseconds == interval.microseconds;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = years;
        result = 31 * result + months;
        result = 31 * result + days;
        result = 31 * result + hours;
        result = 31 * result + minutes;
        result = 31 * result + seconds;
        result = 31 * result + microseconds;
        return result;
    }

    override
    string toString() {
        import std.format;
        import std.math : abs;
        string r = format("Interval( %d years %d months %d days %d hours %d minutes %d%s seconds )",
            years, months, days, hours, minutes, seconds, (microseconds == 0 ? "" : "." ~ abs(microseconds)));
        return r;
    }

    // JsonObject toJson() {
    //     JsonObject json = new JsonObject();
    //     IntervalConverter.toJson(this, json);
    //     return json;
    // }
}
