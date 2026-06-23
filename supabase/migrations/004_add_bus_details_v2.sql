-- Add only the MISSING new columns to buses table for enhanced bus details
-- Skipping: arrival_time (already exists), tripDate, arrivalStatus, estimatedArrivalTime

ALTER TABLE buses
ADD COLUMN IF NOT EXISTS departure_location TEXT,
ADD COLUMN IF NOT EXISTS arrival_location TEXT,
ADD COLUMN IF NOT EXISTS bus_type TEXT,
ADD COLUMN IF NOT EXISTS bus_model TEXT,
ADD COLUMN IF NOT EXISTS bus_schedule_id TEXT,
ADD COLUMN IF NOT EXISTS duration INT,
ADD COLUMN IF NOT EXISTS booking_closing_datetime TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS depot_name TEXT;
