-- Enable Row Level Security on conductors
ALTER TABLE conductors ENABLE ROW LEVEL SECURITY;

-- Allow public read (or restrict to authenticated users/admins as needed)
-- Note: AssignConductorDialog and other views fetch conductors, so we need to make sure they are readable.
CREATE POLICY "Allow public read on conductors" ON conductors
    FOR SELECT USING (true);

-- Allow admins to insert new conductors
CREATE POLICY "Admins can insert conductors" ON conductors
    FOR INSERT WITH CHECK (
        auth.jwt() ->> 'role' = 'admin'
    );

-- Allow admins to update conductors (like assigning buses)
CREATE POLICY "Admins can update conductors" ON conductors
    FOR UPDATE USING (
        auth.jwt() ->> 'role' = 'admin'
    );

-- Allow admins to delete conductors
CREATE POLICY "Admins can delete conductors" ON conductors
    FOR DELETE USING (
        auth.jwt() ->> 'role' = 'admin'
    );

-- Also allow individual conductors to update their own record (e.g., location sharing)
CREATE POLICY "Conductors can update their own record" ON conductors
    FOR UPDATE USING (
        auth.uid() = id
    );
