-- Fix infinite recursion in profiles RLS
-- Issue: Supervisor policy queries profiles while defining policy ON profiles

-- Drop the problematic policy
DROP POLICY IF EXISTS "Supervisors can view all profiles" ON profiles;

-- Create helper function to check if user is supervisor/admin
CREATE OR REPLACE FUNCTION public.is_supervisor_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles
        WHERE id = auth.uid()
        AND role IN ('supervisor', 'admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the supervisor policy using the function
CREATE POLICY "Supervisors can view all profiles"
  ON profiles FOR SELECT
  USING (
    auth.uid() = id  -- Can view own profile
    OR 
    public.is_supervisor_or_admin()  -- Or is a supervisor/admin
  );

COMMENT ON FUNCTION public.is_supervisor_or_admin IS 
  'Check if current user is a supervisor or admin (SECURITY DEFINER to avoid RLS recursion)';
