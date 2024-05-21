CREATE TYPE "unit_type" AS ENUM (
  'switch',
  'compute',
  'storage',
  'custom'
);

CREATE TABLE "datacenters" (
  "id" integer PRIMARY KEY,
  "name" varchar(255) NOT NULL,
  "street" varchar(255) NOT NULL,
  "postcode" varchar(255) NOT NULL,
  "city" varchar(255) NOT NULL,
  "country" varchar(255) NOT NULL
);

CREATE TABLE "datacenter_emissions" (
  "datacenter_id" integer NOT NULL,
  "timestamp" timestamp NOT NULL,
  "outside_temperature" float,
  "outside_humidity" percentage,
  "inside_temperature" float,
  "inside_humidity" percentage,
  "airflow" LFM,
  "outside_pressure" float,
  "dew_point" float,
  "inlet_temperature" float,
  "inlet_humidity" percentage,
  "outlet_temperature" float,
  "outlet_humidity" percentage,
  "power_consumption" float,
  "renewables" float,
  "embedded_emissions" float
);

CREATE TABLE "aisles" (
  "id" integer PRIMARY KEY,
  "datacenter_id" integer NOT NULL,
  "room_id" integer
);

CREATE TABLE "aisle_emissions" (
  "aisle_id" integer NOT NULL,
  "datacenter_id" integer NOT NULL,
  "room_id" integer,
  "timestamp" timestamp NOT NULL,
  "temperature" float,
  "humidity" percentage,
  "airflow" LFM,
  "dew_point" float,
  "inlet_temperature" float,
  "inlet_humidity" percentage,
  "outlet_temperature" float,
  "outlet_humidity" percentage,
  "power_consumption" float,
  "embedded_emissions" float
);

CREATE TABLE "rooms" (
  "id" integer PRIMARY KEY,
  "datacenter_id" integer NOT NULL
);

CREATE TABLE "room_emissions" (
  "room_id" integer NOT NULL,
  "datacenter_id" integer NOT NULL,
  "timestamp" timestamp NOT NULL,
  "temperature" float,
  "humidity" percentage,
  "airflow" LFM,
  "dew_point" float,
  "inlet_temperature" float,
  "inlet_humidity" percentage,
  "outlet_temperature" float,
  "outlet_humidity" percentage,
  "power_consumption" float,
  "embedded_emissions" float
);

CREATE TABLE "racks" (
  "id" integer PRIMARY KEY,
  "datacenter_id" integer NOT NULL,
  "aisle_id" integer,
  "room_id" integer,
  "capacity" integer
);

CREATE TABLE "rack_emissions" (
  "rack_id" integer NOT NULL,
  "datacenter_id" integer NOT NULL,
  "aisle_id" integer,
  "room_id" integer,
  "timestamp" timestamp NOT NULL,
  "temperature" float,
  "humidity" percentage,
  "airflow" LFM,
  "dew_point" float,
  "inlet_temperature" float,
  "inlet_humidity" percentage,
  "outlet_temperature" float,
  "outlet_humidity" percentage,
  "power_consumption" float,
  "embedded_emissions" float
);

CREATE TABLE "units" (
  "id" integer PRIMARY KEY,
  "datacenter_id" integer NOT NULL,
  "rack_id" integer NOT NULL,
  "aisle_id" integer,
  "room_id" integer,
  "type" unit_type NOT NULL,
  "size" integer NOT NULL,
  "description" string
);

CREATE TABLE "unit_emissions" (
  "unit_id" integer NOT NULL,
  "datacenter_id" integer NOT NULL,
  "rack_id" integer NOT NULL,
  "aisle_id" integer,
  "room_id" integer,
  "timestamp" timestamp NOT NULL,
  "temperature" float,
  "humidity" percentage,
  "airflow" LFM,
  "dew_point" float,
  "inlet_temperature" float,
  "inlet_humidity" percentage,
  "outlet_temperature" float,
  "outlet_humidity" percentage,
  "power_consumption" float,
  "fan_speed" float,
  "cpu_utilization" percentage,
  "embedded_emissions" float
);

COMMENT ON COLUMN "datacenter_emissions"."outside_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "datacenter_emissions"."inside_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "datacenter_emissions"."outside_pressure" IS 'hPa';

COMMENT ON COLUMN "datacenter_emissions"."dew_point" IS 'degrees celsius';

COMMENT ON COLUMN "datacenter_emissions"."inlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "datacenter_emissions"."outlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "datacenter_emissions"."power_consumption" IS 'kWh';

COMMENT ON COLUMN "datacenter_emissions"."embedded_emissions" IS 'kt/h';

COMMENT ON COLUMN "aisle_emissions"."temperature" IS 'degrees celsius';

COMMENT ON COLUMN "aisle_emissions"."dew_point" IS 'degrees celsius';

COMMENT ON COLUMN "aisle_emissions"."inlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "aisle_emissions"."outlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "aisle_emissions"."power_consumption" IS 'kWh';

COMMENT ON COLUMN "aisle_emissions"."embedded_emissions" IS 'kt/h';

COMMENT ON COLUMN "room_emissions"."temperature" IS 'degrees celsius';

COMMENT ON COLUMN "room_emissions"."dew_point" IS 'degrees celsius';

COMMENT ON COLUMN "room_emissions"."inlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "room_emissions"."outlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "room_emissions"."power_consumption" IS 'kWh';

COMMENT ON COLUMN "room_emissions"."embedded_emissions" IS 'kt/h';

COMMENT ON COLUMN "racks"."capacity" IS 'sum of the size of units can not exceed this';

COMMENT ON COLUMN "rack_emissions"."temperature" IS 'degrees celsius';

COMMENT ON COLUMN "rack_emissions"."dew_point" IS 'degrees celsius';

COMMENT ON COLUMN "rack_emissions"."inlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "rack_emissions"."outlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "rack_emissions"."power_consumption" IS 'kWh';

COMMENT ON COLUMN "rack_emissions"."embedded_emissions" IS 'kt/h';

COMMENT ON COLUMN "units"."size" IS 'can never be greater than the size of the rack';

COMMENT ON COLUMN "unit_emissions"."temperature" IS 'degrees celsius';

COMMENT ON COLUMN "unit_emissions"."dew_point" IS 'degrees celsius';

COMMENT ON COLUMN "unit_emissions"."inlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "unit_emissions"."outlet_temperature" IS 'degrees celsius';

COMMENT ON COLUMN "unit_emissions"."power_consumption" IS 'kWh';

COMMENT ON COLUMN "unit_emissions"."fan_speed" IS 'RPM';

COMMENT ON COLUMN "unit_emissions"."embedded_emissions" IS 'kt/h';

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "datacenter_emissions" ("datacenter_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "aisles" ("datacenter_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "aisles" ("room_id");

ALTER TABLE "aisles" ADD FOREIGN KEY ("id") REFERENCES "aisle_emissions" ("aisle_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "aisle_emissions" ("datacenter_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "aisle_emissions" ("room_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "rooms" ("datacenter_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "room_emissions" ("room_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "room_emissions" ("datacenter_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "racks" ("datacenter_id");

ALTER TABLE "aisles" ADD FOREIGN KEY ("id") REFERENCES "racks" ("aisle_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "racks" ("room_id");

ALTER TABLE "racks" ADD FOREIGN KEY ("id") REFERENCES "rack_emissions" ("rack_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "rack_emissions" ("datacenter_id");

ALTER TABLE "aisles" ADD FOREIGN KEY ("id") REFERENCES "rack_emissions" ("aisle_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "rack_emissions" ("room_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "units" ("datacenter_id");

ALTER TABLE "racks" ADD FOREIGN KEY ("id") REFERENCES "units" ("rack_id");

ALTER TABLE "aisles" ADD FOREIGN KEY ("id") REFERENCES "units" ("aisle_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "units" ("room_id");

ALTER TABLE "units" ADD FOREIGN KEY ("id") REFERENCES "unit_emissions" ("unit_id");

ALTER TABLE "datacenters" ADD FOREIGN KEY ("id") REFERENCES "unit_emissions" ("datacenter_id");

ALTER TABLE "racks" ADD FOREIGN KEY ("id") REFERENCES "unit_emissions" ("rack_id");

ALTER TABLE "aisles" ADD FOREIGN KEY ("id") REFERENCES "unit_emissions" ("aisle_id");

ALTER TABLE "rooms" ADD FOREIGN KEY ("id") REFERENCES "unit_emissions" ("room_id");
