-- Create patients table
CREATE TABLE IF NOT EXISTS public.patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    full_name TEXT NOT NULL,
    age INTEGER,
    gestational_age_weeks INTEGER,
    risk_level TEXT CHECK (risk_level IN ('High', 'Medium', 'Low')),
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Discharged', 'Transferred')),
    midwife_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    facility_id UUID REFERENCES public.facilities(id) ON DELETE CASCADE,
    last_assessment_date TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

-- Policies

-- Midwives can view their own patients
CREATE POLICY "Midwives can view assigned patients"
    ON public.patients
    FOR SELECT
    USING (midwife_id = auth.uid());

-- Midwives can insert patients (assigning to themselves)
CREATE POLICY "Midwives can create patients"
    ON public.patients
    FOR INSERT
    WITH CHECK (midwife_id = auth.uid());

-- Midwives can update their own patients
CREATE POLICY "Midwives can update assigned patients"
    ON public.patients
    FOR UPDATE
    USING (midwife_id = auth.uid());

-- Supervisors can view all patients in their facility
-- (Refined policy using unit_memberships would go here, for now keeping it simple or skipping strict supervisor view if not needed immediately)
-- Let's allow supervisors to view if they are approved member of the facility
CREATE POLICY "Supervisors can view facility patients"
    ON public.patients
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.unit_memberships
            WHERE user_id = auth.uid()
            AND facility_id = patients.facility_id
            AND role IN ('supervisor', 'admin')
            AND status = 'approved'
        )
    );

-- Add updated_at trigger
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.patients
    FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);
