-- Migration: Create units table
-- Description: Stores units/departments within facilities

CREATE TABLE IF NOT EXISTS public.units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    facility_id UUID NOT NULL REFERENCES public.facilities(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    capacity INTEGER,
    specialization TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_units_facility_id ON public.units(facility_id);
CREATE INDEX IF NOT EXISTS idx_units_name ON public.units(name);

-- Enable Row Level Security
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;

-- RLS Policy: All authenticated users can view units
CREATE POLICY "Authenticated users can view units"
    ON public.units
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policy: Supervisors can create units (for now, allow all authenticated)
CREATE POLICY "Authenticated users can insert units"
    ON public.units
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Supervisors can update their units
CREATE POLICY "Authenticated users can update units"
    ON public.units
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Add trigger for updated_at
CREATE TRIGGER update_units_updated_at
    BEFORE UPDATE ON public.units
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Add comment
COMMENT ON TABLE public.units IS 'Departments/units within healthcare facilities';

-- Insert sample units for testing
INSERT INTO public.units (facility_id, name, description, specialization) 
SELECT 
    f.id,
    'Maternity Ward',
    'Main maternity and delivery ward',
    'Obstetrics'
FROM public.facilities f
WHERE f.name = 'General Hospital Lagos'
LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO public.units (facility_id, name, description, specialization)
SELECT 
    f.id,
    'Emergency Unit',
    'Emergency obstetric care',
    'Emergency'
FROM public.facilities f
WHERE f.name = 'General Hospital Lagos'
LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO public.units (facility_id, name, description, specialization)
SELECT 
    f.id,
    'Birthing Center',
    'Community birthing center',
    'Midwifery'
FROM public.facilities f
WHERE f.name = 'Community Health Center Abuja'
LIMIT 1
ON CONFLICT DO NOTHING;
