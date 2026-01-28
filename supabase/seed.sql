-- Seed data for testing MotivAid
-- Creates test users with known credentials

-- IMPORTANT: This requires creating users via Supabase Auth API
-- Run this SQL after creating the auth users manually or via API

-- For manual testing, create these users in Supabase Studio:
-- 1. supervisor@motivaid.com (password: Test123!)
-- 2. midwife@motivaid.com (password: Test123!)
-- 3. pending@motivaid.com (password: Test123!)

-- Then update their profiles with these SQL statements:

-- Supervisor User Profile (must replace USER_ID with actual auth.users.id)
-- UPDATE profiles 
-- SET 
--   full_name = 'Dr. Sarah Supervisor',
--   phone = '+234-801-234-5678',
--   role = 'supervisor',
--   primary_facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos' LIMIT 1),
--   is_active = true
-- WHERE id = 'SUPERVISOR_USER_ID';

-- Midwife User Profile  
-- UPDATE profiles
-- SET
--   full_name = 'Nurse Mary Midwife',
--   phone = '+234-802-345-6789',
--   role = 'midwife',
--   primary_facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos' LIMIT 1),
--   is_active = true
-- WHERE id = 'MIDWIFE_USER_ID';

-- Pending User Profile (no facility assignment yet)
-- UPDATE profiles
-- SET
--   full_name = 'Jane Pending',
--   phone = '+234-803-456-7890',
--   is_active = true
-- WHERE id = 'PENDING_USER_ID';

-- Create approved membership for supervisor
-- INSERT INTO unit_memberships (profile_id, unit_id, role, status, approved_at)
-- VALUES (
--   'SUPERVISOR_USER_ID',
--   (SELECT id FROM units WHERE name = 'Maternity Ward' AND facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos') LIMIT 1),
--   'supervisor',
--   'approved',
--   NOW()
-- );

-- Create approved membership for midwife
-- INSERT INTO unit_memberships (profile_id, unit_id, role, status, approved_at)
-- VALUES (
--   'MIDWIFE_USER_ID',
--   (SELECT id FROM units WHERE name = 'Maternity Ward' AND facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos') LIMIT 1),
--   'midwife',
--   'approved',
--   NOW()
-- );

-- NOTE: The Pending User (pending@motivaid.com) should NOT have a unit_membership
-- This user will appear in the supervisor's "Pending User Approvals" screen


-- ============================================================================
-- EASIER APPROACH: Use Supabase Dashboard or npx supabase test db reset --seed
-- ============================================================================

COMMENT ON TABLE public.profiles IS 'Test users:
- supervisor@motivaid.com (password: Test123!) - Can assign users
- midwife@motivaid.com (password: Test123!) - Regular user with access
- pending@motivaid.com (password: Test123!) - Awaiting assignment';
