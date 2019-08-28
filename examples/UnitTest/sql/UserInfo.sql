
-- ----------------------------
-- Table structure for UserInfo
-- ----------------------------
DROP TABLE IF EXISTS "public"."UserInfo";
CREATE TABLE "public"."UserInfo" (
  "uid" int4 NOT NULL DEFAULT nextval('userinfo_uid_seq'::regclass),
  "username" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "departname" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "created" timestamp(6),
  "height" float8,
  "avatar" bytea
)
;

-- ----------------------------
-- Records of UserInfo
-- ----------------------------
INSERT INTO "public"."UserInfo" VALUES (1, 'putao', '研发', '2019-08-27 23:12:37.345', 1.75, E'\\253\\315\\340');

-- ----------------------------
-- Primary Key structure for table UserInfo
-- ----------------------------
ALTER TABLE "public"."UserInfo" ADD CONSTRAINT "userinfo_pkey" PRIMARY KEY ("uid");

CREATE SEQUENCE "public"."userinfo_uid_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

SELECT setval('"public"."userinfo_uid_seq"', 3, true);

ALTER SEQUENCE "public"."userinfo_uid_seq"
OWNED BY "public"."UserInfo"."uid";

ALTER SEQUENCE "public"."userinfo_uid_seq" OWNER TO "postgres";
