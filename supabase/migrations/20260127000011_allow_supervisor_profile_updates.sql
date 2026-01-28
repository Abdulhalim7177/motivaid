-- Allow supervisors/admins to UPDATE other users' profiles
-- This is needed for the assignment workflow where supervisors set facility/role

-- Create policy for supervisors to update all profiles
CREATE POLICY "Supervisors can update all profiles"
  ON profiles FOR UPDATE
  USING (public.is_supervisor_or_admin())
  WITH CHECK (public.is_supervisor_or_admin());

COMMENT ON POLICY "Supervisors can update all profiles" ON profiles IS 
  'Allow supervisors and admins to update any user profile for assignment purposes';
