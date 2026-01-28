-- Migration: Update profiles table with role and enhanced fields
-- Description: Add role, primary facility, and other fields to profiles

-- Add new columns to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS role public.user_role DEFAULT 'midwife',
ADD COLUMN IF NOT EXISTS primary_facility_id UUID REFERENCES public.facilities(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS certifications JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Create index on role and facility
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_facility_id ON public.profiles(primary_facility_id);

-- Update existing profiles to have a default facility (first one)
UPDATE public.profiles
SET primary_facility_id = (SELECT id FROM public.facilities LIMIT 1)
WHERE primary_facility_id IS NULL;

-- Add comment
COMMENT ON COLUMN public.profiles.role IS 'User role: midwife, supervisor, or admin';
COMMENT ON COLUMN public.profiles.primary_facility_id IS 'Primary facility where user works';
COMMENT ON COLUMN public.profiles.certifications IS 'Array of certification documents and details';
COMMENT ON COLUMN public.profiles.is_active IS 'Whether the user account is active';
