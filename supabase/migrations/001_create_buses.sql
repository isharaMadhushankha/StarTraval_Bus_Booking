-- Create buses table
CREATE TABLE buses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bus_no TEXT NOT NULL,
    route TEXT NOT NULL,
    departure_time TIMESTAMPTZ NOT NULL,
    total_seats INT NOT NULL,
    price_per_seat FLOAT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    status_note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public buses are viewable by everyone." ON buses
    FOR SELECT USING (true);

CREATE POLICY "Admins can insert buses." ON buses
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admins can update buses." ON buses
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admins can delete buses." ON buses
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');
