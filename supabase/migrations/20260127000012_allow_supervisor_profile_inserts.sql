-- Allow supervisors/admins to INSERT profiles (for future admin features)
-- Note: Creating auth.users still requires Supabase Admin API

-- Create policy for supervisors to insert profiles
CREATE POLICY "Supervisors can insert profiles"
  ON profiles FOR INSERT
  WITH CHECK (
    auth.uid() = id  -- Can insert own profile
    OR 
    public.is_supervisor_or_admin()  -- Or is supervisor/admin
  );

COMMENT ON POLICY "Supervisors can insert profiles" ON profiles IS 
  'Allow supervisors and admins to create profiles (requires auth.users to exist first)';
