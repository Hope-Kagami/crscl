-- Enable PostGIS extension for location-based features
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create enum for service types
CREATE TYPE service_type AS ENUM (
  'oil_change',
  'brake_service',
  'tire_service',
  'battery_service',
  'engine_repair',
  'transmission_repair',
  'ac_service',
  'electrical_repair',
  'body_repair',
  'inspection',
  'general_maintenance'
);

-- Create repair centers table
CREATE TABLE repair_centers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  email VARCHAR(255),
  website VARCHAR(255),
  image_url TEXT,
  description TEXT,
  location GEOGRAPHY(POINT) NOT NULL,
  services service_type[] NOT NULL DEFAULT '{}',
  rating DECIMAL(3,2) NOT NULL DEFAULT 0.0,
  review_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create business hours table
CREATE TABLE repair_center_hours (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  repair_center_id UUID REFERENCES repair_centers(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  open_time TIME,
  close_time TIME,
  is_closed BOOLEAN NOT NULL DEFAULT false,
  UNIQUE(repair_center_id, day_of_week)
);

-- Create function to get repair centers within radius
CREATE OR REPLACE FUNCTION get_repair_centers_within_radius(
  ref_lat DOUBLE PRECISION,
  ref_lon DOUBLE PRECISION,
  radius_km DOUBLE PRECISION
) RETURNS TABLE (
  id UUID,
  name VARCHAR(255),
  address TEXT,
  phone_number VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  image_url TEXT,
  description TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  services service_type[],
  rating DECIMAL(3,2),
  review_count INTEGER,
  distance DOUBLE PRECISION,
  is_open BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  WITH current_time_at_timezone AS (
    SELECT EXTRACT(DOW FROM CURRENT_TIMESTAMP AT TIME ZONE 'UTC') + 1 as current_day,
           CURRENT_TIME AS current_time
  )
  SELECT 
    rc.id,
    rc.name,
    rc.address,
    rc.phone_number,
    rc.email,
    rc.website,
    rc.image_url,
    rc.description,
    ST_Y(location::geometry) AS latitude,
    ST_X(location::geometry) AS longitude,
    rc.services,
    rc.rating,
    rc.review_count,
    ST_Distance(
      location::geometry,
      ST_SetSRID(ST_MakePoint(ref_lon, ref_lat), 4326)
    ) / 1000 AS distance,
    EXISTS (
      SELECT 1
      FROM repair_center_hours rch, current_time_at_timezone ct
      WHERE rch.repair_center_id = rc.id
        AND rch.day_of_week = ct.current_day
        AND NOT rch.is_closed
        AND ct.current_time BETWEEN rch.open_time AND rch.close_time
    ) AS is_open
  FROM repair_centers rc
  WHERE ST_DWithin(
    location::geometry,
    ST_SetSRID(ST_MakePoint(ref_lon, ref_lat), 4326),
    radius_km * 1000
  )
  ORDER BY distance;
END;
$$ LANGUAGE plpgsql;
