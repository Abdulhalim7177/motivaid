-- Fix RLS policies for public access during registration
-- Facilities and units need to be viewable by unauthenticated users during signup

-- Drop existing policies
DROP POLICY IF EXISTS "Facilities are viewable by authenticated users" ON facilities;
DROP POLICY IF EXISTS "Units are viewable by authenticated users" ON units;

-- Create new policies allowing public read access
CREATE POLICY "Facilities are viewable by everyone"
  ON facilities FOR SELECT
  USING (true);

CREATE POLICY "Units are viewable by everyone"
  ON units FOR SELECT
  USING (true);

-- Keep write access restricted to authenticated users
CREATE POLICY "Facilities can be created by authenticated users"
  ON facilities FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Units can be created by authenticated users"
  ON units FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

COMMENT ON POLICY "Facilities are viewable by everyone" ON facilities IS 
  'Allow public read access to facilities for registration flow';

COMMENT ON POLICY "Units are viewable by everyone" ON units IS 
  'Allow public read access to units for registration flow';
