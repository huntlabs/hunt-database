
-- ----------------------------
-- Table structure for Fortune
-- ----------------------------
DROP TABLE IF EXISTS "public"."Fortune";
CREATE TABLE "public"."Fortune" (
  "id" int4 NOT NULL,
  "message" varchar(2048) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of Fortune
-- ----------------------------
INSERT INTO "public"."Fortune" VALUES (1, 'fortune: No such file or directory');
INSERT INTO "public"."Fortune" VALUES (2, 'A computer scientist is someone who fixes things that aren''t broken.');
INSERT INTO "public"."Fortune" VALUES (3, 'After enough decimal places, nobody gives a damn.');
INSERT INTO "public"."Fortune" VALUES (4, 'A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1');
INSERT INTO "public"."Fortune" VALUES (5, 'A computer program does what you tell it to do, not what you want it to do.');
INSERT INTO "public"."Fortune" VALUES (6, 'Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen');
INSERT INTO "public"."Fortune" VALUES (7, 'Any program that runs right is obsolete.');
INSERT INTO "public"."Fortune" VALUES (8, 'A list is only as strong as its weakest link. — Donald Knuth');
INSERT INTO "public"."Fortune" VALUES (9, 'Feature: A bug with seniority.');
INSERT INTO "public"."Fortune" VALUES (10, 'Computers make very fast, very accurate mistakes.');
INSERT INTO "public"."Fortune" VALUES (11, '<script>alert("This should not be displayed in a browser alert box.");</script>');
INSERT INTO "public"."Fortune" VALUES (12, 'フレームワークのベンチマーク');

-- ----------------------------
-- Primary Key structure for table Fortune
-- ----------------------------
ALTER TABLE "public"."Fortune" ADD CONSTRAINT "Fortune_pkey" PRIMARY KEY ("id");
