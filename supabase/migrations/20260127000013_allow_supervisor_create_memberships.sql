-- Allow supervisors/admins to create unit_memberships for other users
-- This is needed for the supervisor assignment workflow

-- Create INSERT policy for supervisors
CREATE POLICY "Supervisors can create memberships"
  ON unit_memberships FOR INSERT
  WITH CHECK (public.is_supervisor_or_admin());

COMMENT ON POLICY "Supervisors can create memberships" ON unit_memberships IS 
  'Allow supervisors and admins to create unit memberships for users during assignment';
