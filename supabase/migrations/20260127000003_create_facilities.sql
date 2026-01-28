-- Migration: Create facilities table
-- Description: Stores healthcare facilities (hospitals, clinics)

CREATE TABLE IF NOT EXISTS public.facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index on name for search
CREATE INDEX IF NOT EXISTS idx_facilities_name ON public.facilities(name);

-- Enable Row Level Security
ALTER TABLE public.facilities ENABLE ROW LEVEL SECURITY;

-- RLS Policy: All authenticated users can view facilities
CREATE POLICY "Authenticated users can view facilities"
    ON public.facilities
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policy: Only admins can insert facilities (for now, allow all authenticated)
CREATE POLICY "Authenticated users can insert facilities"
    ON public.facilities
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Only admins can update facilities
CREATE POLICY "Authenticated users can update facilities"
    ON public.facilities
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Add trigger for updated_at
CREATE TRIGGER update_facilities_updated_at
    BEFORE UPDATE ON public.facilities
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Add comment
COMMENT ON TABLE public.facilities IS 'Healthcare facilities where units are located';

-- Insert sample facility for testing
INSERT INTO public.facilities (name, location, address, phone) VALUES
('General Hospital Lagos', 'Lagos State', '123 Hospital Road, Lagos', '+234-800-1234567'),
('Community Health Center Abuja', 'FCT Abuja', '45 Community Ave, Abuja', '+234-800-7654321')
ON CONFLICT DO NOTHING;
