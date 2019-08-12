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
module hunt.database.base.data.Numeric;

import hunt.Double;
import hunt.Exceptions;
import hunt.Float;
import hunt.Long;
import hunt.Integer;
import hunt.math.BigDecimal;
import hunt.math.BigInteger;
import hunt.Number;

import std.concurrency : initOnce;


/**
 * The Postgres <i>NUMERIC</i> type.
 */
final class Numeric : Number {

    /**
     * Constant for the {@code NaN} value.
     */
    static Numeric NaN() {
        __gshared Numeric inst;
        return initOnce!inst(new Numeric(Double.NaN));
    }

    private Number value;

    /**
     * Return a {@code Numeric} instance for the given {@code number}.
     * <p/>
     * Null values or infinite {@code Double} or {@code Float} are rejected.
     *
     * @param number the number
     * @return the {@code Numeric} value
     * @throws NumberFormatException when the number is infinite
     */
    static Numeric create(Number number) {
        if (number is null) {
            throw new NullPointerException();
        
        Double d = cast(Double)number;
        Float f = cast(Float)number;

        if (d !is null && d.isInfinite() || f !is null && f.isInfinite()) {
            throw new NumberFormatException("Infinite numbers are not valid numerics");
        }
        return new Numeric(number);
    }

    /**
     * Parse and return a {@code Numeric} instance for the given {@code s}.
     * <p/>
     * The string {@code "Nan"} will return the {@link #NaN} instance.
     *
     * @param s the string
     * @return the {@code Numeric} value
     */
    static Numeric parse(string s) {
        switch (s) {
            case "NaN":
                return NaN;
            default:
                return new Numeric(new BigDecimal(s));
        }
    }

    private this(Number value) {
        this.value = value;
    }

    override
    short shortValue() {
        return value.shortValue();
    }

    override
    int intValue() {
        return value.intValue();
    }

    override
    long longValue() {
        return value.longValue();
    }

    override
    float floatValue() {
        return value.floatValue();
    }

    override
    double doubleValue() {
        return value.doubleValue();
    }

    /**
     * @return {@code true} when this number represents {@code NaN}
     */
    bool isNaN() {
        Double d = cast(Double)value;
        Float f = cast(Float)value;
        return d !is null && d.isNaN() || f !is null && f.isNaN();
    }

    /**
     * @return  the numeric value represented by this object after conversion
     *          to type {@code BigDecimal}. It can be {@code null} when this instance
     *          represents the {@code NaN} value.
     */
    BigDecimal bigDecimalValue() {
        BigDecimal bd = cast(BigDecimal) value;
        if (bd !is null) {
            return bd;
        } 

        BigInteger bi = cast(BigInteger)value;
        if (bi !is null) {
            return new BigDecimal(bi);
        } else if (isNaN()) {
            return null;
        } else {
            return new BigDecimal(value.toString());
        }
    }

    /**
     * @return  the numeric value represented by this object after conversion
     *          to type {@code BigInteger}. It can be {@code null} when this instance
     *          represents the {@code NaN} value.
     */
    BigInteger bigIntegerValue() {
        BigInteger bi = cast(BigInteger)value;
        if (bi !is null) {
            return bi;
        }

        BigDecimal bd = cast(BigDecimal)value;
        if (bd !is null) {
            return bd.toBigInteger();
        } else if (isNaN()) {
            return null;
        } else {
            return new BigInteger(Long.toString(value.longValue()));
        }
    }

    override
    bool opEquals(Object obj) {
        Numeric that = cast(Numeric) obj;
        if (that !is null) {
            if (typeid(value)  == typeid(that)) {
                return value == that.value;
            } else {
                BigDecimal l = bigDecimalValue();
                BigDecimal r = that.bigDecimalValue();
                if (l is null) {
                    return r is null;
                } else if (r is null) {
                    return false;
                }
                
                // TODO: Tasks pending completion -@zxp at 8/12/2019, 3:15:15 PM
                // 
                // return l == r;
                return l.compareTo(r) == 0;
            }
        }
        return false;
    }

    override
    size_t toHash() @trusted nothrow {
        return cast(size_t)intValue();
    }

    override
    string toString() {
        return value.toString();
    }
}
