-- Fix profiles RLS to allow supervisors/admins to view all profiles
-- Supervisors need to see pending users to assign them

-- Drop existing SELECT policy
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- Create new policies
-- 1. Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- 2. Supervisors and admins can view all profiles
CREATE POLICY "Supervisors can view all profiles"
  ON profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('supervisor', 'admin')
    )
  );

COMMENT ON POLICY "Supervisors can view all profiles" ON profiles IS 
  'Allow supervisors and admins to view all user profiles for assignment purposes';
