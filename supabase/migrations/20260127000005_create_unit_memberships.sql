-- Migration: Create unit_memberships table  
-- Description: Many-to-many relationship between profiles and units with approval workflow

-- Create enum for membership status
CREATE TYPE public.membership_status AS ENUM ('pending', 'approved', 'rejected');

-- Create enum for user roles
CREATE TYPE public.user_role AS ENUM ('midwife', 'supervisor', 'admin');

CREATE TABLE IF NOT EXISTS public.unit_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES public.units(id) ON DELETE CASCADE,
    role public.user_role NOT NULL DEFAULT 'midwife',
    status public.membership_status NOT NULL DEFAULT 'pending',
    approved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Ensure a user can't have duplicate memberships in same unit
    UNIQUE(profile_id, unit_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_memberships_profile_id ON public.unit_memberships(profile_id);
CREATE INDEX IF NOT EXISTS idx_memberships_unit_id ON public.unit_memberships(unit_id);
CREATE INDEX IF NOT EXISTS idx_memberships_status ON public.unit_memberships(status);

-- Enable Row Level Security
ALTER TABLE public.unit_memberships ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own memberships
CREATE POLICY "Users can view own memberships"
    ON public.unit_memberships
    FOR SELECT
    USING (auth.uid() = profile_id);

-- RLS Policy: Supervisors can view memberships for their units
CREATE POLICY "Supervisors can view unit memberships"
    ON public.unit_memberships
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.unit_memberships um
            WHERE um.profile_id = auth.uid()
            AND um.unit_id = public.unit_memberships.unit_id
            AND um.role IN ('supervisor', 'admin')
            AND um.status = 'approved'
        )
    );

-- RLS Policy: Users can insert their own membership requests
CREATE POLICY "Users can request unit membership"
    ON public.unit_memberships
    FOR INSERT
    WITH CHECK (auth.uid() = profile_id);

-- RLS Policy: Supervisors can update memberships in their units
CREATE POLICY "Supervisors can update unit memberships"
    ON public.unit_memberships
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.unit_memberships um
            WHERE um.profile_id = auth.uid()
            AND um.unit_id = public.unit_memberships.unit_id
            AND um.role IN ('supervisor', 'admin')
            AND um.status = 'approved'
        )
    );

-- Add trigger for updated_at
CREATE TRIGGER update_unit_memberships_updated_at
    BEFORE UPDATE ON public.unit_memberships
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Add comment
COMMENT ON TABLE public.unit_memberships IS 'User memberships to units with approval workflow';
