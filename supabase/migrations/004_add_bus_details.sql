-- Add new columns to buses table for enhanced bus details
-- This migration adds support for detailed bus information

ALTER TABLE buses
ADD COLUMN departure_location TEXT,
ADD COLUMN arrival_location TEXT,
ADD COLUMN bus_type TEXT,
ADD COLUMN bus_model TEXT,
ADD COLUMN bus_schedule_id TEXT,
ADD COLUMN arrival_time TIMESTAMPTZ,
ADD COLUMN duration INT,
ADD COLUMN booking_closing_datetime TIMESTAMPTZ,
ADD COLUMN depot_name TEXT;

-- Add comment documenting the new columns
COMMENT ON COLUMN buses.departure_location IS 'Specific departure location (e.g., Colombo Central)';
COMMENT ON COLUMN buses.arrival_location IS 'Specific arrival location (e.g., Kandy Central)';
COMMENT ON COLUMN buses.bus_type IS 'Type of bus (Normal, AC, Luxury, etc.)';
COMMENT ON COLUMN buses.bus_model IS 'Bus model/manufacturer (Ashok Leyland, Tata, etc.)';
COMMENT ON COLUMN buses.bus_schedule_id IS 'Unique schedule identifier (e.g., BT4898-1810-GP50)';
COMMENT ON COLUMN buses.arrival_time IS 'Expected arrival time at destination';
COMMENT ON COLUMN buses.duration IS 'Travel duration in minutes';
COMMENT ON COLUMN buses.booking_closing_datetime IS 'When booking closes for this trip';
COMMENT ON COLUMN buses.depot_name IS 'Operating depot name (e.g., Central Depot, Batticaloa)';
