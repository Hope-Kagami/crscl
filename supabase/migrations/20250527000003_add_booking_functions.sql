-- Create function to get available time slots
CREATE OR REPLACE FUNCTION get_available_time_slots(
  repair_center_id UUID,
  date_to_check DATE
) RETURNS TABLE (
  time_slot TIME
) AS $$
DECLARE
  interval_minutes INTEGER := 30; -- 30-minute slots
  opening_time TIME;
  closing_time TIME;
BEGIN
  -- Get business hours for the specified day
  SELECT 
    open_time,
    close_time
  INTO
    opening_time,
    closing_time
  FROM repair_center_hours
  WHERE repair_center_id = $1
    AND day_of_week = EXTRACT(DOW FROM date_to_check) + 1
    AND NOT is_closed;

  -- If the repair center is closed on this day, return no slots
  IF opening_time IS NULL OR closing_time IS NULL THEN
    RETURN;
  END IF;

  -- Generate time slots
  RETURN QUERY
  WITH RECURSIVE time_slots AS (
    SELECT opening_time AS slot
    UNION ALL
    SELECT slot + (interval_minutes * INTERVAL '1 minute')
    FROM time_slots
    WHERE slot + (interval_minutes * INTERVAL '1 minute') <= closing_time - (interval_minutes * INTERVAL '1 minute')
  )
  SELECT slot::TIME
  FROM time_slots t
  WHERE NOT EXISTS (
    -- Check existing appointments
    SELECT 1
    FROM appointments a
    WHERE a.repair_center_id = $1
      AND a.appointment_date = date_to_check
      AND a.appointment_time = t.slot
  )
  ORDER BY slot;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a repair center is currently open
CREATE OR REPLACE FUNCTION is_repair_center_open(repair_center_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM repair_center_hours
    WHERE repair_center_id = $1
      AND day_of_week = EXTRACT(DOW FROM CURRENT_TIMESTAMP AT TIME ZONE 'UTC') + 1
      AND NOT is_closed
      AND CURRENT_TIME BETWEEN open_time AND close_time
  );
END;
$$ LANGUAGE plpgsql;
