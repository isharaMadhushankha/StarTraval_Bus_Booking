-- Function to generate seats for a new bus
CREATE OR REPLACE FUNCTION generate_bus_seats()
RETURNS TRIGGER AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..NEW.total_seats LOOP
        INSERT INTO seats (bus_id, seat_number, status)
        VALUES (NEW.id, i, 'available');
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to generate seats after a bus is inserted
CREATE TRIGGER trigger_generate_bus_seats
AFTER INSERT ON buses
FOR EACH ROW
EXECUTE FUNCTION generate_bus_seats();

-- Function to release expired 'selecting' seats (older than 5 mins)
CREATE OR REPLACE FUNCTION release_expired_seats()
RETURNS VOID AS $$
BEGIN
    UPDATE seats
    SET status = 'available',
        last_touched_by = NULL
    WHERE status = 'selecting'
      AND updated_at < NOW() - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
