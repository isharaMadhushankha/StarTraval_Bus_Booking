-- Create seats table
CREATE TABLE seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bus_id UUID REFERENCES buses(id) ON DELETE CASCADE,
    seat_number INT NOT NULL,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'selecting', 'booked')),
    last_touched_by UUID,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public seats are viewable by everyone." ON seats
    FOR SELECT USING (true);

CREATE POLICY "Users can update seat status to selecting." ON seats
    FOR UPDATE USING (true) WITH CHECK (status IN ('available', 'selecting'));

CREATE POLICY "Admins can manage all seats." ON seats
    FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

-- Function to update updated_at on change
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_seats_updated_at BEFORE UPDATE ON seats
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
