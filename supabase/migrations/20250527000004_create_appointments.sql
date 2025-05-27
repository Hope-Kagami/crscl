-- Create appointments table
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  repair_center_id UUID NOT NULL REFERENCES repair_centers(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  description TEXT,
  services service_type[] NOT NULL DEFAULT '{}',
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add trigger for updated_at
CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Enable RLS
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own appointments"
ON appointments FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own appointments"
ON appointments FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own appointments"
ON appointments FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- Add indexes
CREATE INDEX idx_appointments_user ON appointments(user_id);
CREATE INDEX idx_appointments_repair_center ON appointments(repair_center_id);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
