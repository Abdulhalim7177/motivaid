-- Fix infinite recursion in unit_memberships RLS policies
-- The issue: policies were querying unit_memberships while defining policies ON unit_memberships

-- Drop the problematic policies
DROP POLICY IF EXISTS "Supervisors can view unit memberships" ON public.unit_memberships;
DROP POLICY IF EXISTS "Supervisors can update unit memberships" ON public.unit_memberships;

-- Simplified supervisor policies that don't cause recursion
-- For now, supervisors need to be approved members of a unit to manage it
-- We'll use a function to avoid recursion

-- Create helper function to check if user is supervisor
CREATE OR REPLACE FUNCTION public.is_supervisor_of_unit(p_unit_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.unit_memberships
        WHERE profile_id = auth.uid()
        AND unit_id = p_unit_id
        AND role IN ('supervisor', 'admin')
        AND status = 'approved'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- New simplified SELECT policy for supervisors (avoids recursion by using function)
CREATE POLICY "Supervisors can view unit memberships"
    ON public.unit_memberships
    FOR SELECT
    USING (
        auth.uid() = profile_id  -- Own memberships
        OR 
        public.is_supervisor_of_unit(unit_id)  -- Supervisor of the unit
    );

-- New simplified UPDATE policy for supervisors
CREATE POLICY "Supervisors can update unit memberships"
    ON public.unit_memberships
    FOR UPDATE
    USING (public.is_supervisor_of_unit(unit_id));

COMMENT ON FUNCTION public.is_supervisor_of_unit IS 
    'Check if current user is an approved supervisor/admin of a unit';
