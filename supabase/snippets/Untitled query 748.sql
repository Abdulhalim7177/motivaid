-- After creating supervisor@motivaid.com
UPDATE profiles 
SET 
  full_name = 'Dr. Sarah Supervisor',
  phone = '+234-801-234-5678',
  role = 'supervisor',
  primary_facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos' LIMIT 1)
WHERE email = 'supervisor@motivaid.com';

-- Create supervisor's unit membership
INSERT INTO unit_memberships (profile_id, unit_id, role, status, approved_at)
VALUES (
  (SELECT id FROM profiles WHERE email = 'supervisor@motivaid.com'),
  (SELECT id FROM units WHERE name = 'Maternity Ward' LIMIT 1),
  'supervisor',
  'approved',
  NOW()
);

-- After creating midwife@motivaid.com
UPDATE profiles 
SET 
  full_name = 'Nurse Mary Midwife',
  phone = '+234-802-345-6789',
  role = 'midwife',
  primary_facility_id = (SELECT id FROM facilities WHERE name = 'General Hospital Lagos' LIMIT 1)
WHERE email = 'midwife@motivaid.com';

-- Create midwife's unit membership
INSERT INTO unit_memberships (profile_id, unit_id, role, status, approved_at)
VALUES (
  (SELECT id FROM profiles WHERE email = 'midwife@motivaid.com'),
  (SELECT id FROM units WHERE name = 'Maternity Ward' LIMIT 1),
  'midwife',
  'approved',
  NOW()
);

-- After creating pending@motivaid.com
UPDATE profiles 
SET 
  full_name = 'Jane Pending',
  phone = '+234-803-456-7890'
WHERE email = 'pending@motivaid.com';
