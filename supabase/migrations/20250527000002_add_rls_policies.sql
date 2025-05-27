-- Enable RLS
ALTER TABLE repair_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE repair_center_hours ENABLE ROW LEVEL SECURITY;

-- Create policies for repair_centers
CREATE POLICY "Enable read access for authenticated users" ON repair_centers FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON repair_centers FOR INSERT
  TO authenticated WITH CHECK (auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  ));

CREATE POLICY "Enable update access for admins" ON repair_centers FOR UPDATE
  TO authenticated USING (auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  ));

-- Create policies for repair_center_hours
CREATE POLICY "Enable read access for authenticated users" ON repair_center_hours FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON repair_center_hours FOR INSERT
  TO authenticated WITH CHECK (auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  ));

CREATE POLICY "Enable update access for admins" ON repair_center_hours FOR UPDATE
  TO authenticated USING (auth.uid() IN (
    SELECT id FROM users WHERE role = 'admin'
  ));
