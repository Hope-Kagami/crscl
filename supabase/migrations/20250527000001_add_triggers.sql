-- Add trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger to repair_centers table
CREATE TRIGGER update_repair_centers_updated_at
    BEFORE UPDATE ON repair_centers
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();
