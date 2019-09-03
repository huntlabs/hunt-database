module hunt.database.mysql.impl.MySQLCollation;

import hunt.util.ObjectUtils;
import hunt.Exceptions;

import std.array;
import std.conv;

/**
 * MySQL collation which is a set of rules for comparing characters in a character set.
 */
struct MySQLCollation {
    enum MySQLCollation big5_chinese_ci = MySQLCollation("big5", "Big5", 1);
    enum MySQLCollation latin2_czech_cs = MySQLCollation("latin2", "ISO8859_2", 2);
    enum MySQLCollation dec8_swedish_ci = MySQLCollation("dec8", "Cp1252", 3);
    enum MySQLCollation cp850_general_ci = MySQLCollation("cp850", "Cp850", 4);
    enum MySQLCollation latin1_german1_ci = MySQLCollation("latin1", "Cp1252", 5);
    enum MySQLCollation hp8_english_ci = MySQLCollation("hp8", "Cp1252", 6);
    enum MySQLCollation koi8r_general_ci = MySQLCollation("koi8r", "KOI8_R", 7);
    enum MySQLCollation latin1_swedish_ci = MySQLCollation("latin1", "Cp1252", 8);
    enum MySQLCollation latin2_general_ci = MySQLCollation("latin2", "ISO8859_2", 9);
    enum MySQLCollation swe7_swedish_ci = MySQLCollation("swe7", "Cp1252", 10);
    enum MySQLCollation ascii_general_ci = MySQLCollation("ascii", "US-ASCII", 11);
    enum MySQLCollation ujis_japanese_ci = MySQLCollation("ujis", "EUC_JP", 12);
    enum MySQLCollation sjis_japanese_ci = MySQLCollation("sjis", "SJIS", 13);
    enum MySQLCollation cp1251_bulgarian_ci = MySQLCollation("cp1251", "Cp1251", 14);
    enum MySQLCollation latin1_danish_ci = MySQLCollation("latin1", "Cp1252", 15);
    enum MySQLCollation hebrew_general_ci = MySQLCollation("hebrew", "ISO8859_8", 16);
    enum MySQLCollation tis620_thai_ci = MySQLCollation("tis620", "TIS620", 18);
    enum MySQLCollation euckr_korean_ci = MySQLCollation("euckr", "EUC_KR", 19);
    enum MySQLCollation latin7_estonian_cs = MySQLCollation("latin7", "ISO-8859-13", 20);
    enum MySQLCollation latin2_hungarian_ci = MySQLCollation("latin2", "ISO8859_2", 21);
    enum MySQLCollation koi8u_general_ci = MySQLCollation("koi8u", "KOI8_R", 22);
    enum MySQLCollation cp1251_ukrainian_ci = MySQLCollation("cp1251", "Cp1251", 23);
    enum MySQLCollation gb2312_chinese_ci = MySQLCollation("gb2312", "EUC_CN", 24);
    enum MySQLCollation greek_general_ci = MySQLCollation("greek", "ISO8859_7", 25);
    enum MySQLCollation cp1250_general_ci = MySQLCollation("cp1250", "Cp1250", 26);
    enum MySQLCollation latin2_croatian_ci = MySQLCollation("latin2", "ISO8859_2", 27);
    enum MySQLCollation gbk_chinese_ci = MySQLCollation("gbk", "GBK", 28);
    enum MySQLCollation cp1257_lithuanian_ci = MySQLCollation("cp1257", "Cp1257", 29);
    enum MySQLCollation latin5_turkish_ci = MySQLCollation("latin5", "ISO8859_9", 30);
    enum MySQLCollation latin1_german2_ci = MySQLCollation("latin1", "Cp1252", 31);
    enum MySQLCollation armscii8_general_ci = MySQLCollation("armscii8", "Cp1252", 32);
    enum MySQLCollation utf8_general_ci = MySQLCollation("utf8", "UTF-8", 33);
    enum MySQLCollation cp1250_czech_cs = MySQLCollation("cp1250", "Cp1250", 34);
    enum MySQLCollation ucs2_general_ci = MySQLCollation("ucs2", "UnicodeBig", 35);
    enum MySQLCollation cp866_general_ci = MySQLCollation("cp866", "Cp866", 36);
    enum MySQLCollation keybcs2_general_ci = MySQLCollation("keybcs2", "Cp852", 37);
    enum MySQLCollation macce_general_ci = MySQLCollation("macce", "MacCentralEurope", 38);
    enum MySQLCollation macroman_general_ci = MySQLCollation("macroman", "MacRoman", 39);
    enum MySQLCollation cp852_general_ci = MySQLCollation("cp852", "Cp852", 40);
    enum MySQLCollation latin7_general_ci = MySQLCollation("latin7", "ISO-8859-13", 41);
    enum MySQLCollation latin7_general_cs = MySQLCollation("latin7", "ISO-8859-13", 42);
    enum MySQLCollation macce_bin = MySQLCollation("macce", "MacCentralEurope", 43);
    enum MySQLCollation cp1250_croatian_ci = MySQLCollation("cp1250", "Cp1250", 44);
    enum MySQLCollation utf8mb4_general_ci = MySQLCollation("utf8mb4", "UTF-8", 45);
    enum MySQLCollation utf8mb4_bin = MySQLCollation("utf8mb4", "UTF-8", 46);
    enum MySQLCollation latin1_bin = MySQLCollation("latin1", "Cp1252", 47);
    enum MySQLCollation latin1_general_ci = MySQLCollation("latin1", "Cp1252", 48);
    enum MySQLCollation latin1_general_cs = MySQLCollation("latin1", "Cp1252", 49);
    enum MySQLCollation cp1251_bin = MySQLCollation("cp1251", "Cp1251", 50);
    enum MySQLCollation cp1251_general_ci = MySQLCollation("cp1251", "Cp1251", 51);
    enum MySQLCollation cp1251_general_cs = MySQLCollation("cp1251", "Cp1251", 52);
    enum MySQLCollation macroman_bin = MySQLCollation("macroman", "MacRoman", 53);
    enum MySQLCollation utf16_general_ci = MySQLCollation("utf16", "UTF-16", 54);
    enum MySQLCollation utf16_bin = MySQLCollation("utf16", "UTF-16", 55);
    enum MySQLCollation utf16le_general_ci = MySQLCollation("utf16le", "UTF-16LE", 56);
    enum MySQLCollation cp1256_general_ci = MySQLCollation("cp1256", "Cp1256", 57);
    enum MySQLCollation cp1257_bin = MySQLCollation("cp1257", "Cp1257", 58);
    enum MySQLCollation cp1257_general_ci = MySQLCollation("cp1257", "Cp1257", 59);
    enum MySQLCollation utf32_general_ci = MySQLCollation("utf32", "UTF-32", 60);
    enum MySQLCollation utf32_bin = MySQLCollation("utf32", "UTF-32", 61);
    enum MySQLCollation utf16le_bin = MySQLCollation("utf16le", "UTF-16LE", 62);
    enum MySQLCollation binary = MySQLCollation("binary", "ISO8859_1", 63);
    enum MySQLCollation armscii8_bin = MySQLCollation("armscii8", "Cp1252", 64);
    enum MySQLCollation ascii_bin = MySQLCollation("ascii", "US-ASCII", 65);
    enum MySQLCollation cp1250_bin = MySQLCollation("cp1250", "Cp1250", 66);
    enum MySQLCollation cp1256_bin = MySQLCollation("cp1256", "Cp1256", 67);
    enum MySQLCollation cp866_bin = MySQLCollation("cp866", "Cp866", 68);
    enum MySQLCollation dec8_bin = MySQLCollation("dec8", "Cp1252", 69);
    enum MySQLCollation greek_bin = MySQLCollation("greek", "ISO8859_7", 70);
    enum MySQLCollation hebrew_bin = MySQLCollation("hebrew", "ISO8859_8", 71);
    enum MySQLCollation hp8_bin = MySQLCollation("hp8", "Cp1252", 72);
    enum MySQLCollation keybcs2_bin = MySQLCollation("keybcs2", "Cp852", 73);
    enum MySQLCollation koi8r_bin = MySQLCollation("koi8r", "KOI8_R", 74);
    enum MySQLCollation koi8u_bin = MySQLCollation("koi8u", "KOI8_R", 75);
    enum MySQLCollation latin2_bin = MySQLCollation("latin2", "ISO8859_2", 77);
    enum MySQLCollation latin5_bin = MySQLCollation("latin5", "ISO8859_9", 78);
    enum MySQLCollation latin7_bin = MySQLCollation("latin7", "ISO-8859-13", 79);
    enum MySQLCollation cp850_bin = MySQLCollation("cp850", "Cp850", 80);
    enum MySQLCollation cp852_bin = MySQLCollation("cp852", "Cp852", 81);
    enum MySQLCollation swe7_bin = MySQLCollation("swe7", "Cp1252", 82);
    enum MySQLCollation utf8_bin = MySQLCollation("utf8", "UTF-8", 83);
    enum MySQLCollation big5_bin = MySQLCollation("big5", "Big5", 84);
    enum MySQLCollation euckr_bin = MySQLCollation("euckr", "EUC_KR", 85);
    enum MySQLCollation gb2312_bin = MySQLCollation("gb2312", "EUC_CN", 86);
    enum MySQLCollation gbk_bin = MySQLCollation("gbk", "GBK", 87);
    enum MySQLCollation sjis_bin = MySQLCollation("sjis", "SJIS", 88);
    enum MySQLCollation tis620_bin = MySQLCollation("tis620", "TIS620", 89);
    enum MySQLCollation ucs2_bin = MySQLCollation("ucs2", "UnicodeBig", 90);
    enum MySQLCollation ujis_bin = MySQLCollation("ujis", "EUC_JP", 91);
    enum MySQLCollation geostd8_general_ci = MySQLCollation("geostd8", "Cp1252", 92);
    enum MySQLCollation geostd8_bin = MySQLCollation("geostd8", "Cp1252", 93);
    enum MySQLCollation latin1_spanish_ci = MySQLCollation("latin1", "Cp1252", 94);
    enum MySQLCollation cp932_japanese_ci = MySQLCollation("cp932", "Cp932", 95);
    enum MySQLCollation cp932_bin = MySQLCollation("cp932", "Cp932", 96);
    enum MySQLCollation eucjpms_japanese_ci = MySQLCollation("eucjpms", "EUC_JP_Solaris", 97);
    enum MySQLCollation eucjpms_bin = MySQLCollation("eucjpms", "EUC_JP_Solaris", 98);
    enum MySQLCollation cp1250_polish_ci = MySQLCollation("cp1250", "Cp1250", 99);
    enum MySQLCollation utf16_unicode_ci = MySQLCollation("utf16", "UTF-16", 101);
    enum MySQLCollation utf16_icelandic_ci = MySQLCollation("utf16", "UTF-16", 102);
    enum MySQLCollation utf16_latvian_ci = MySQLCollation("utf16", "UTF-16", 103);
    enum MySQLCollation utf16_romanian_ci = MySQLCollation("utf16", "UTF-16", 104);
    enum MySQLCollation utf16_slovenian_ci = MySQLCollation("utf16", "UTF-16", 105);
    enum MySQLCollation utf16_polish_ci = MySQLCollation("utf16", "UTF-16", 106);
    enum MySQLCollation utf16_estonian_ci = MySQLCollation("utf16", "UTF-16", 107);
    enum MySQLCollation utf16_spanish_ci = MySQLCollation("utf16", "UTF-16", 108);
    enum MySQLCollation utf16_swedish_ci = MySQLCollation("utf16", "UTF-16", 109);
    enum MySQLCollation utf16_turkish_ci = MySQLCollation("utf16", "UTF-16", 110);
    enum MySQLCollation utf16_czech_ci = MySQLCollation("utf16", "UTF-16", 111);
    enum MySQLCollation utf16_danish_ci = MySQLCollation("utf16", "UTF-16", 112);
    enum MySQLCollation utf16_lithuanian_ci = MySQLCollation("utf16", "UTF-16", 113);
    enum MySQLCollation utf16_slovak_ci = MySQLCollation("utf16", "UTF-16", 114);
    enum MySQLCollation utf16_spanish2_ci = MySQLCollation("utf16", "UTF-16", 115);
    enum MySQLCollation utf16_roman_ci = MySQLCollation("utf16", "UTF-16", 116);
    enum MySQLCollation utf16_persian_ci = MySQLCollation("utf16", "UTF-16", 117);
    enum MySQLCollation utf16_esperanto_ci = MySQLCollation("utf16", "UTF-16", 118);
    enum MySQLCollation utf16_hungarian_ci = MySQLCollation("utf16", "UTF-16", 119);
    enum MySQLCollation utf16_sinhala_ci = MySQLCollation("utf16", "UTF-16", 120);
    enum MySQLCollation utf16_german2_ci = MySQLCollation("utf16", "UTF-16", 121);
    enum MySQLCollation utf16_croatian_ci = MySQLCollation("utf16", "UTF-16", 122);
    enum MySQLCollation utf16_unicode_520_ci = MySQLCollation("utf16", "UTF-16", 123);
    enum MySQLCollation utf16_vietnamese_ci = MySQLCollation("utf16", "UTF-16", 124);
    enum MySQLCollation ucs2_unicode_ci = MySQLCollation("ucs2", "UnicodeBig", 128);
    enum MySQLCollation ucs2_icelandic_ci = MySQLCollation("ucs2", "UnicodeBig", 129);
    enum MySQLCollation ucs2_latvian_ci = MySQLCollation("ucs2", "UnicodeBig", 130);
    enum MySQLCollation ucs2_romanian_ci = MySQLCollation("ucs2", "UnicodeBig", 131);
    enum MySQLCollation ucs2_slovenian_ci = MySQLCollation("ucs2", "UnicodeBig", 132);
    enum MySQLCollation ucs2_polish_ci = MySQLCollation("ucs2", "UnicodeBig", 133);
    enum MySQLCollation ucs2_estonian_ci = MySQLCollation("ucs2", "UnicodeBig", 134);
    enum MySQLCollation ucs2_spanish_ci = MySQLCollation("ucs2", "UnicodeBig", 135);
    enum MySQLCollation ucs2_swedish_ci = MySQLCollation("ucs2", "UnicodeBig", 136);
    enum MySQLCollation ucs2_turkish_ci = MySQLCollation("ucs2", "UnicodeBig", 137);
    enum MySQLCollation ucs2_czech_ci = MySQLCollation("ucs2", "UnicodeBig", 138);
    enum MySQLCollation ucs2_danish_ci = MySQLCollation("ucs2", "UnicodeBig", 139);
    enum MySQLCollation ucs2_lithuanian_ci = MySQLCollation("ucs2", "UnicodeBig", 140);
    enum MySQLCollation ucs2_slovak_ci = MySQLCollation("ucs2", "UnicodeBig", 141);
    enum MySQLCollation ucs2_spanish2_ci = MySQLCollation("ucs2", "UnicodeBig", 142);
    enum MySQLCollation ucs2_roman_ci = MySQLCollation("ucs2", "UnicodeBig", 143);
    enum MySQLCollation ucs2_persian_ci = MySQLCollation("ucs2", "UnicodeBig", 144);
    enum MySQLCollation ucs2_esperanto_ci = MySQLCollation("ucs2", "UnicodeBig", 145);
    enum MySQLCollation ucs2_hungarian_ci = MySQLCollation("ucs2", "UnicodeBig", 146);
    enum MySQLCollation ucs2_sinhala_ci = MySQLCollation("ucs2", "UnicodeBig", 147);
    enum MySQLCollation ucs2_german2_ci = MySQLCollation("ucs2", "UnicodeBig", 148);
    enum MySQLCollation ucs2_croatian_ci = MySQLCollation("ucs2", "UnicodeBig", 149);
    enum MySQLCollation ucs2_unicode_520_ci = MySQLCollation("ucs2", "UnicodeBig", 150);
    enum MySQLCollation ucs2_vietnamese_ci = MySQLCollation("ucs2", "UnicodeBig", 151);
    enum MySQLCollation ucs2_general_mysql500_ci = MySQLCollation("ucs2", "UnicodeBig", 159);
    enum MySQLCollation utf32_unicode_ci = MySQLCollation("utf32", "UTF-32", 160);
    enum MySQLCollation utf32_icelandic_ci = MySQLCollation("utf32", "UTF-32", 161);
    enum MySQLCollation utf32_latvian_ci = MySQLCollation("utf32", "UTF-32", 162);
    enum MySQLCollation utf32_romanian_ci = MySQLCollation("utf32", "UTF-32", 163);
    enum MySQLCollation utf32_slovenian_ci = MySQLCollation("utf32", "UTF-32", 164);
    enum MySQLCollation utf32_polish_ci = MySQLCollation("utf32", "UTF-32", 165);
    enum MySQLCollation utf32_estonian_ci = MySQLCollation("utf32", "UTF-32", 166);
    enum MySQLCollation utf32_spanish_ci = MySQLCollation("utf32", "UTF-32", 167);
    enum MySQLCollation utf32_swedish_ci = MySQLCollation("utf32", "UTF-32", 168);
    enum MySQLCollation utf32_turkish_ci = MySQLCollation("utf32", "UTF-32", 169);
    enum MySQLCollation utf32_czech_ci = MySQLCollation("utf32", "UTF-32", 170);
    enum MySQLCollation utf32_danish_ci = MySQLCollation("utf32", "UTF-32", 171);
    enum MySQLCollation utf32_lithuanian_ci = MySQLCollation("utf32", "UTF-32", 172);
    enum MySQLCollation utf32_slovak_ci = MySQLCollation("utf32", "UTF-32", 173);
    enum MySQLCollation utf32_spanish2_ci = MySQLCollation("utf32", "UTF-32", 174);
    enum MySQLCollation utf32_roman_ci = MySQLCollation("utf32", "UTF-32", 175);
    enum MySQLCollation utf32_persian_ci = MySQLCollation("utf32", "UTF-32", 176);
    enum MySQLCollation utf32_esperanto_ci = MySQLCollation("utf32", "UTF-32", 177);
    enum MySQLCollation utf32_hungarian_ci = MySQLCollation("utf32", "UTF-32", 178);
    enum MySQLCollation utf32_sinhala_ci = MySQLCollation("utf32", "UTF-32", 179);
    enum MySQLCollation utf32_german2_ci = MySQLCollation("utf32", "UTF-32", 180);
    enum MySQLCollation utf32_croatian_ci = MySQLCollation("utf32", "UTF-32", 181);
    enum MySQLCollation utf32_unicode_520_ci = MySQLCollation("utf32", "UTF-32", 182);
    enum MySQLCollation utf32_vietnamese_ci = MySQLCollation("utf32", "UTF-32", 183);
    enum MySQLCollation utf8_unicode_ci = MySQLCollation("utf8", "UTF-8", 192);
    enum MySQLCollation utf8_icelandic_ci = MySQLCollation("utf8", "UTF-8", 193);
    enum MySQLCollation utf8_latvian_ci = MySQLCollation("utf8", "UTF-8", 194);
    enum MySQLCollation utf8_romanian_ci = MySQLCollation("utf8", "UTF-8", 195);
    enum MySQLCollation utf8_slovenian_ci = MySQLCollation("utf8", "UTF-8", 196);
    enum MySQLCollation utf8_polish_ci = MySQLCollation("utf8", "UTF-8", 197);
    enum MySQLCollation utf8_estonian_ci = MySQLCollation("utf8", "UTF-8", 198);
    enum MySQLCollation utf8_spanish_ci = MySQLCollation("utf8", "UTF-8", 199);
    enum MySQLCollation utf8_swedish_ci = MySQLCollation("utf8", "UTF-8", 200);
    enum MySQLCollation utf8_turkish_ci = MySQLCollation("utf8", "UTF-8", 201);
    enum MySQLCollation utf8_czech_ci = MySQLCollation("utf8", "UTF-8", 202);
    enum MySQLCollation utf8_danish_ci = MySQLCollation("utf8", "UTF-8", 203);
    enum MySQLCollation utf8_lithuanian_ci = MySQLCollation("utf8", "UTF-8", 204);
    enum MySQLCollation utf8_slovak_ci = MySQLCollation("utf8", "UTF-8", 205);
    enum MySQLCollation utf8_spanish2_ci = MySQLCollation("utf8", "UTF-8", 206);
    enum MySQLCollation utf8_roman_ci = MySQLCollation("utf8", "UTF-8", 207);
    enum MySQLCollation utf8_persian_ci = MySQLCollation("utf8", "UTF-8", 208);
    enum MySQLCollation utf8_esperanto_ci = MySQLCollation("utf8", "UTF-8", 209);
    enum MySQLCollation utf8_hungarian_ci = MySQLCollation("utf8", "UTF-8", 210);
    enum MySQLCollation utf8_sinhala_ci = MySQLCollation("utf8", "UTF-8", 211);
    enum MySQLCollation utf8_german2_ci = MySQLCollation("utf8", "UTF-8", 212);
    enum MySQLCollation utf8_croatian_ci = MySQLCollation("utf8", "UTF-8", 213);
    enum MySQLCollation utf8_unicode_520_ci = MySQLCollation("utf8", "UTF-8", 214);
    enum MySQLCollation utf8_vietnamese_ci = MySQLCollation("utf8", "UTF-8", 215);
    enum MySQLCollation utf8_general_mysql500_ci = MySQLCollation("utf8", "UTF-8", 223);
    enum MySQLCollation utf8mb4_unicode_ci = MySQLCollation("utf8mb4", "UTF-8", 224);
    enum MySQLCollation utf8mb4_icelandic_ci = MySQLCollation("utf8mb4", "UTF-8", 225);
    enum MySQLCollation utf8mb4_latvian_ci = MySQLCollation("utf8mb4", "UTF-8", 226);
    enum MySQLCollation utf8mb4_romanian_ci = MySQLCollation("utf8mb4", "UTF-8", 227);
    enum MySQLCollation utf8mb4_slovenian_ci = MySQLCollation("utf8mb4", "UTF-8", 228);
    enum MySQLCollation utf8mb4_polish_ci = MySQLCollation("utf8mb4", "UTF-8", 229);
    enum MySQLCollation utf8mb4_estonian_ci = MySQLCollation("utf8mb4", "UTF-8", 230);
    enum MySQLCollation utf8mb4_spanish_ci = MySQLCollation("utf8mb4", "UTF-8", 231);
    enum MySQLCollation utf8mb4_swedish_ci = MySQLCollation("utf8mb4", "UTF-8", 232);
    enum MySQLCollation utf8mb4_turkish_ci = MySQLCollation("utf8mb4", "UTF-8", 233);
    enum MySQLCollation utf8mb4_czech_ci = MySQLCollation("utf8mb4", "UTF-8", 234);
    enum MySQLCollation utf8mb4_danish_ci = MySQLCollation("utf8mb4", "UTF-8", 235);
    enum MySQLCollation utf8mb4_lithuanian_ci = MySQLCollation("utf8mb4", "UTF-8", 236);
    enum MySQLCollation utf8mb4_slovak_ci = MySQLCollation("utf8mb4", "UTF-8", 237);
    enum MySQLCollation utf8mb4_spanish2_ci = MySQLCollation("utf8mb4", "UTF-8", 238);
    enum MySQLCollation utf8mb4_roman_ci = MySQLCollation("utf8mb4", "UTF-8", 239);
    enum MySQLCollation utf8mb4_persian_ci = MySQLCollation("utf8mb4", "UTF-8", 240);
    enum MySQLCollation utf8mb4_esperanto_ci = MySQLCollation("utf8mb4", "UTF-8", 241);
    enum MySQLCollation utf8mb4_hungarian_ci = MySQLCollation("utf8mb4", "UTF-8", 242);
    enum MySQLCollation utf8mb4_sinhala_ci = MySQLCollation("utf8mb4", "UTF-8", 243);
    enum MySQLCollation utf8mb4_german2_ci = MySQLCollation("utf8mb4", "UTF-8", 244);
    enum MySQLCollation utf8mb4_croatian_ci = MySQLCollation("utf8mb4", "UTF-8", 245);
    enum MySQLCollation utf8mb4_unicode_520_ci = MySQLCollation("utf8mb4", "UTF-8", 246);
    enum MySQLCollation utf8mb4_vietnamese_ci = MySQLCollation("utf8mb4", "UTF-8", 247);
    enum MySQLCollation gb18030_chinese_ci = MySQLCollation("gb18030", "GB18030", 248);
    enum MySQLCollation gb18030_bin = MySQLCollation("gb18030", "GB18030", 249);
    enum MySQLCollation gb18030_unicode_520_ci = MySQLCollation("gb18030", "GB18030", 250);

    enum string[string] charsetToDefaultCollationMapping = [
        "big5" : "big5_chinese_ci",
        "dec8" : "dec8_swedish_ci",
        "cp850" : "cp850_general_ci",
        "hp8" : "hp8_english_ci",
        "koi8r" : "koi8r_general_ci",
        "latin1" : "latin1_swedish_ci",
        "latin2" : "latin2_general_ci",
        "swe7" : "swe7_swedish_ci",
        "ascii" : "ascii_general_ci",
        "ujis" : "ujis_japanese_ci",
        "sjis" : "sjis_japanese_ci",
        "hebrew" : "hebrew_general_ci",
        "tis620" : "tis620_thai_ci",
        "euckr" : "euckr_korean_ci",
        "koi8u" : "koi8u_general_ci",
        "gb2312" : "gb2312_chinese_ci",
        "greek" : "greek_general_ci",
        "cp1250" : "cp1250_general_ci",
        "gbk" : "gbk_chinese_ci",
        "latin5" : "latin5_turkish_ci",
        "armscii8" : "armscii8_general_ci",
        "utf8" : "utf8_general_ci",
        "ucs2" : "ucs2_general_ci",
        "cp866" : "cp866_general_ci",
        "keybcs2" : "keybcs2_general_ci",
        "macce" : "macce_general_ci",
        "macroman" : "macroman_general_ci",
        "cp852" : "cp852_general_ci",
        "latin7" : "latin7_general_ci",
        "utf8mb4" : "utf8mb4_general_ci",
        "cp1251" : "cp1251_general_ci",
        "utf16" : "utf16_general_ci",
        "utf16le" : "utf16le_general_ci",
        "cp1256" : "cp1256_general_ci",
        "cp1257" : "cp1257_general_ci",
        "utf32" : "utf32_general_ci",
        "binary" : "binary",
        "geostd8" : "geostd8_general_ci",
        "cp932" : "cp932_japanese_ci",
        "eucjpms" : "eucjpms_japanese_ci",
        "gb18030" : "gb18030_chinese_ci"
    ];


    mixin ValuesMemberTempate!MySQLCollation;

    private string _mysqlCharsetName;
    private string _mappedJavaCharsetName;
    private int _collationId;

    this(string mysqlCharsetName, string mappedJavaCharsetName, int collationId) {
        this._mysqlCharsetName = mysqlCharsetName;
        this._mappedJavaCharsetName = mappedJavaCharsetName;
        this._collationId = collationId;
    }

    static MySQLCollation valueOf(string collationName) {
        auto itemPtr = collationName in namedValues();
        if(itemPtr !is null) {
            return *itemPtr;
        }
        
        throw new IllegalArgumentException(collationName);
    }
    

    static MySQLCollation valueOfName(string collationName) {
        try {
            return MySQLCollation.valueOf(collationName);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Unknown MySQL collation: [" ~ collationName ~ "]");
        }
    }

    /**
     * Get the MySQL collation with a correlative collation id.
     *
     * @param collationId id of the collation
     * @return the collation
     */
    static MySQLCollation valueOfId(int collationId) {
        switch (collationId) {
            case 1:
                return big5_chinese_ci;
            case 2:
                return latin2_czech_cs;
            case 3:
                return dec8_swedish_ci;
            case 4:
                return cp850_general_ci;
            case 5:
                return latin1_german1_ci;
            case 6:
                return hp8_english_ci;
            case 7:
                return koi8r_general_ci;
            case 8:
                return latin1_swedish_ci;
            case 9:
                return latin2_general_ci;
            case 10:
                return swe7_swedish_ci;
            case 11:
                return ascii_general_ci;
            case 12:
                return ujis_japanese_ci;
            case 13:
                return sjis_japanese_ci;
            case 14:
                return cp1251_bulgarian_ci;
            case 15:
                return latin1_danish_ci;
            case 16:
                return hebrew_general_ci;
            case 18:
                return tis620_thai_ci;
            case 19:
                return euckr_korean_ci;
            case 20:
                return latin7_estonian_cs;
            case 21:
                return latin2_hungarian_ci;
            case 22:
                return koi8u_general_ci;
            case 23:
                return cp1251_ukrainian_ci;
            case 24:
                return gb2312_chinese_ci;
            case 25:
                return greek_general_ci;
            case 26:
                return cp1250_general_ci;
            case 27:
                return latin2_croatian_ci;
            case 28:
                return gbk_chinese_ci;
            case 29:
                return cp1257_lithuanian_ci;
            case 30:
                return latin5_turkish_ci;
            case 31:
                return latin1_german2_ci;
            case 32:
                return armscii8_general_ci;
            case 33:
                return utf8_general_ci;
            case 34:
                return cp1250_czech_cs;
            case 35:
                return ucs2_general_ci;
            case 36:
                return cp866_general_ci;
            case 37:
                return keybcs2_general_ci;
            case 38:
                return macce_general_ci;
            case 39:
                return macroman_general_ci;
            case 40:
                return cp852_general_ci;
            case 41:
                return latin7_general_ci;
            case 42:
                return latin7_general_cs;
            case 43:
                return macce_bin;
            case 44:
                return cp1250_croatian_ci;
            case 45:
                return utf8mb4_general_ci;
            case 46:
                return utf8mb4_bin;
            case 47:
                return latin1_bin;
            case 48:
                return latin1_general_ci;
            case 49:
                return latin1_general_cs;
            case 50:
                return cp1251_bin;
            case 51:
                return cp1251_general_ci;
            case 52:
                return cp1251_general_cs;
            case 53:
                return macroman_bin;
            case 54:
                return utf16_general_ci;
            case 55:
                return utf16_bin;
            case 56:
                return utf16le_general_ci;
            case 57:
                return cp1256_general_ci;
            case 58:
                return cp1257_bin;
            case 59:
                return cp1257_general_ci;
            case 60:
                return utf32_general_ci;
            case 61:
                return utf32_bin;
            case 62:
                return utf16le_bin;
            case 63:
                return binary;
            case 64:
                return armscii8_bin;
            case 65:
                return ascii_bin;
            case 66:
                return cp1250_bin;
            case 67:
                return cp1256_bin;
            case 68:
                return cp866_bin;
            case 69:
                return dec8_bin;
            case 70:
                return greek_bin;
            case 71:
                return hebrew_bin;
            case 72:
                return hp8_bin;
            case 73:
                return keybcs2_bin;
            case 74:
                return koi8r_bin;
            case 75:
                return koi8u_bin;
            case 77:
                return latin2_bin;
            case 78:
                return latin5_bin;
            case 79:
                return latin7_bin;
            case 80:
                return cp850_bin;
            case 81:
                return cp852_bin;
            case 82:
                return swe7_bin;
            case 83:
                return utf8_bin;
            case 84:
                return big5_bin;
            case 85:
                return euckr_bin;
            case 86:
                return gb2312_bin;
            case 87:
                return gbk_bin;
            case 88:
                return sjis_bin;
            case 89:
                return tis620_bin;
            case 90:
                return ucs2_bin;
            case 91:
                return ujis_bin;
            case 92:
                return geostd8_general_ci;
            case 93:
                return geostd8_bin;
            case 94:
                return latin1_spanish_ci;
            case 95:
                return cp932_japanese_ci;
            case 96:
                return cp932_bin;
            case 97:
                return eucjpms_japanese_ci;
            case 98:
                return eucjpms_bin;
            case 99:
                return cp1250_polish_ci;
            case 101:
                return utf16_unicode_ci;
            case 102:
                return utf16_icelandic_ci;
            case 103:
                return utf16_latvian_ci;
            case 104:
                return utf16_romanian_ci;
            case 105:
                return utf16_slovenian_ci;
            case 106:
                return utf16_polish_ci;
            case 107:
                return utf16_estonian_ci;
            case 108:
                return utf16_spanish_ci;
            case 109:
                return utf16_swedish_ci;
            case 110:
                return utf16_turkish_ci;
            case 111:
                return utf16_czech_ci;
            case 112:
                return utf16_danish_ci;
            case 113:
                return utf16_lithuanian_ci;
            case 114:
                return utf16_slovak_ci;
            case 115:
                return utf16_spanish2_ci;
            case 116:
                return utf16_roman_ci;
            case 117:
                return utf16_persian_ci;
            case 118:
                return utf16_esperanto_ci;
            case 119:
                return utf16_hungarian_ci;
            case 120:
                return utf16_sinhala_ci;
            case 121:
                return utf16_german2_ci;
            case 122:
                return utf16_croatian_ci;
            case 123:
                return utf16_unicode_520_ci;
            case 124:
                return utf16_vietnamese_ci;
            case 128:
                return ucs2_unicode_ci;
            case 129:
                return ucs2_icelandic_ci;
            case 130:
                return ucs2_latvian_ci;
            case 131:
                return ucs2_romanian_ci;
            case 132:
                return ucs2_slovenian_ci;
            case 133:
                return ucs2_polish_ci;
            case 134:
                return ucs2_estonian_ci;
            case 135:
                return ucs2_spanish_ci;
            case 136:
                return ucs2_swedish_ci;
            case 137:
                return ucs2_turkish_ci;
            case 138:
                return ucs2_czech_ci;
            case 139:
                return ucs2_danish_ci;
            case 140:
                return ucs2_lithuanian_ci;
            case 141:
                return ucs2_slovak_ci;
            case 142:
                return ucs2_spanish2_ci;
            case 143:
                return ucs2_roman_ci;
            case 144:
                return ucs2_persian_ci;
            case 145:
                return ucs2_esperanto_ci;
            case 146:
                return ucs2_hungarian_ci;
            case 147:
                return ucs2_sinhala_ci;
            case 148:
                return ucs2_german2_ci;
            case 149:
                return ucs2_croatian_ci;
            case 150:
                return ucs2_unicode_520_ci;
            case 151:
                return ucs2_vietnamese_ci;
            case 159:
                return ucs2_general_mysql500_ci;
            case 160:
                return utf32_unicode_ci;
            case 161:
                return utf32_icelandic_ci;
            case 162:
                return utf32_latvian_ci;
            case 163:
                return utf32_romanian_ci;
            case 164:
                return utf32_slovenian_ci;
            case 165:
                return utf32_polish_ci;
            case 166:
                return utf32_estonian_ci;
            case 167:
                return utf32_spanish_ci;
            case 168:
                return utf32_swedish_ci;
            case 169:
                return utf32_turkish_ci;
            case 170:
                return utf32_czech_ci;
            case 171:
                return utf32_danish_ci;
            case 172:
                return utf32_lithuanian_ci;
            case 173:
                return utf32_slovak_ci;
            case 174:
                return utf32_spanish2_ci;
            case 175:
                return utf32_roman_ci;
            case 176:
                return utf32_persian_ci;
            case 177:
                return utf32_esperanto_ci;
            case 178:
                return utf32_hungarian_ci;
            case 179:
                return utf32_sinhala_ci;
            case 180:
                return utf32_german2_ci;
            case 181:
                return utf32_croatian_ci;
            case 182:
                return utf32_unicode_520_ci;
            case 183:
                return utf32_vietnamese_ci;
            case 192:
                return utf8_unicode_ci;
            case 193:
                return utf8_icelandic_ci;
            case 194:
                return utf8_latvian_ci;
            case 195:
                return utf8_romanian_ci;
            case 196:
                return utf8_slovenian_ci;
            case 197:
                return utf8_polish_ci;
            case 198:
                return utf8_estonian_ci;
            case 199:
                return utf8_spanish_ci;
            case 200:
                return utf8_swedish_ci;
            case 201:
                return utf8_turkish_ci;
            case 202:
                return utf8_czech_ci;
            case 203:
                return utf8_danish_ci;
            case 204:
                return utf8_lithuanian_ci;
            case 205:
                return utf8_slovak_ci;
            case 206:
                return utf8_spanish2_ci;
            case 207:
                return utf8_roman_ci;
            case 208:
                return utf8_persian_ci;
            case 209:
                return utf8_esperanto_ci;
            case 210:
                return utf8_hungarian_ci;
            case 211:
                return utf8_sinhala_ci;
            case 212:
                return utf8_german2_ci;
            case 213:
                return utf8_croatian_ci;
            case 214:
                return utf8_unicode_520_ci;
            case 215:
                return utf8_vietnamese_ci;
            case 223:
                return utf8_general_mysql500_ci;
            case 224:
                return utf8mb4_unicode_ci;
            case 225:
                return utf8mb4_icelandic_ci;
            case 226:
                return utf8mb4_latvian_ci;
            case 227:
                return utf8mb4_romanian_ci;
            case 228:
                return utf8mb4_slovenian_ci;
            case 229:
                return utf8mb4_polish_ci;
            case 230:
                return utf8mb4_estonian_ci;
            case 231:
                return utf8mb4_spanish_ci;
            case 232:
                return utf8mb4_swedish_ci;
            case 233:
                return utf8mb4_turkish_ci;
            case 234:
                return utf8mb4_czech_ci;
            case 235:
                return utf8mb4_danish_ci;
            case 236:
                return utf8mb4_lithuanian_ci;
            case 237:
                return utf8mb4_slovak_ci;
            case 238:
                return utf8mb4_spanish2_ci;
            case 239:
                return utf8mb4_roman_ci;
            case 240:
                return utf8mb4_persian_ci;
            case 241:
                return utf8mb4_esperanto_ci;
            case 242:
                return utf8mb4_hungarian_ci;
            case 243:
                return utf8mb4_sinhala_ci;
            case 244:
                return utf8mb4_german2_ci;
            case 245:
                return utf8mb4_croatian_ci;
            case 246:
                return utf8mb4_unicode_520_ci;
            case 247:
                return utf8mb4_vietnamese_ci;
            case 248:
                return gb18030_chinese_ci;
            case 249:
                return gb18030_bin;
            case 250:
                return gb18030_unicode_520_ci;
            default:
                throw new UnsupportedOperationException("Collation of Id [" ~ 
                    collationId.to!string() ~ "] is unknown to this client");
        }
    }

    static string getDefaultCollationFromCharsetName(string charset) {
        string defaultCollationName = charsetToDefaultCollationMapping.get(charset, null);
        if (defaultCollationName.empty()) {
            throw new IllegalArgumentException("Unknown charset name: [" ~ charset ~ "]");
        } else {
            return defaultCollationName;
        }
    }

    /**
     * Get the binding MySQL charset name for this collation.
     *
     * @return the binding MySQL charset name
     */
    string mysqlCharsetName() {
        return _mysqlCharsetName;
    }

    /**
     * Get the mapped Java charset name which is mapped from the collation.
     *
     * @return the mapped Java charset name
     */
    string mappedJavaCharsetName() {
        return _mappedJavaCharsetName;
    }

    /**
     * Get the collation Id of this collation
     *
     * @return the collation Id
     */
    int collationId() {
        return _collationId;
    }
}
