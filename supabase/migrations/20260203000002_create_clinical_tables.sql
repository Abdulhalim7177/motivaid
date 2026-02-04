-- Create pph_cases table
CREATE TABLE IF NOT EXISTS public.pph_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID REFERENCES public.facilities(id),
    unit_id UUID REFERENCES public.units(id),
    patient_id UUID REFERENCES public.patients(id) NOT NULL,
    midwife_id UUID REFERENCES public.profiles(id) NOT NULL,
    case_number TEXT,
    delivery_time TIMESTAMPTZ,
    pph_detected_time TIMESTAMPTZ,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'referred', 'death')),
    blood_loss_ml INTEGER DEFAULT 0,
    shock_index DECIMAL(4,2),
    outcome TEXT CHECK (outcome IN ('resolved', 'referred', 'death')),
    notes TEXT,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for pph_cases
ALTER TABLE public.pph_cases ENABLE ROW LEVEL SECURITY;

-- Policies for pph_cases
CREATE POLICY "Midwives view cases in their facility"
    ON public.pph_cases FOR SELECT
    USING (
        facility_id IN (
            SELECT u.facility_id 
            FROM public.unit_memberships um
            JOIN public.units u ON um.unit_id = u.id
            WHERE um.profile_id = auth.uid() AND um.status = 'approved'
        )
    );

CREATE POLICY "Midwives create cases"
    ON public.pph_cases FOR INSERT
    WITH CHECK (midwife_id = auth.uid());

CREATE POLICY "Midwives update own cases"
    ON public.pph_cases FOR UPDATE
    USING (midwife_id = auth.uid());


-- Create interventions table
CREATE TABLE IF NOT EXISTS public.interventions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pph_case_id UUID REFERENCES public.pph_cases(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('early_detection', 'uterine_massage', 'oxytocin', 'misoprostol', 'tranexamic_acid', 'iv_fluids', 'examination', 'escalation', 'referral', 'other')),
    name TEXT NOT NULL,
    performed_at TIMESTAMPTZ DEFAULT NOW(),
    performed_by UUID REFERENCES public.profiles(id) NOT NULL,
    dosage TEXT,
    route TEXT,
    notes TEXT,
    is_completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for interventions
ALTER TABLE public.interventions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "View interventions for visible cases"
    ON public.interventions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.pph_cases c
            WHERE c.id = interventions.pph_case_id
            AND (
                c.facility_id IN (
                    SELECT u.facility_id 
                    FROM public.unit_memberships um
                    JOIN public.units u ON um.unit_id = u.id
                    WHERE um.profile_id = auth.uid() AND um.status = 'approved'
                )
            )
        )
    );

CREATE POLICY "Create interventions"
    ON public.interventions FOR INSERT
    WITH CHECK (performed_by = auth.uid());


-- Create vital_signs table
CREATE TABLE IF NOT EXISTS public.vital_signs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pph_case_id UUID REFERENCES public.pph_cases(id) ON DELETE CASCADE NOT NULL,
    heart_rate INTEGER,
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    shock_index DECIMAL(4,2),
    temperature DECIMAL(3,1),
    respiratory_rate INTEGER,
    spo2 INTEGER,
    recorded_at TIMESTAMPTZ DEFAULT NOW(),
    recorded_by UUID REFERENCES public.profiles(id) NOT NULL
);

-- Enable RLS for vital_signs
ALTER TABLE public.vital_signs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "View vitals for visible cases"
    ON public.vital_signs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.pph_cases c
            WHERE c.id = vital_signs.pph_case_id
            AND (
                c.facility_id IN (
                    SELECT u.facility_id 
                    FROM public.unit_memberships um
                    JOIN public.units u ON um.unit_id = u.id
                    WHERE um.profile_id = auth.uid() AND um.status = 'approved'
                )
            )
        )
    );

CREATE POLICY "Create vital signs"
    ON public.vital_signs FOR INSERT
    WITH CHECK (recorded_by = auth.uid());

-- Triggers for updated_at
CREATE TRIGGER update_pph_cases_updated_at
    BEFORE UPDATE ON public.pph_cases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
