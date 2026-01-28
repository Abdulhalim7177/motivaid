# Test Users & Seed Data

## Quick Test Users

For easy testing, create these users via Supabase Studio Auth section:

### 1. Supervisor Account
- **Email:** `supervisor@motivaid.com`
- **Password:** `Test123!`
- **Role:** Supervisor
- **Facility:** General Hospital Lagos
- **Unit:** Maternity Ward
- **Can:** Assign pending users

### 2. Midwife Account
- **Email:** `midwife@motivaid.com`
- **Password:** `Test123!`
- **Role:** Midwife
- **Facility:** General Hospital Lagos
- **Unit:** Maternity Ward
- **Can:** Access dashboard (regular user)

### 3. Pending User
- **Email:** `pending@motivaid.com`
- **Password:** `Test123!`
- **Status:** No facility assignment
- **Sees:** "Awaiting Assignment" screen
- **Purpose:** Test supervisor assignment flow

## How to Create Test Users

### Option 1: Via Supabase Studio (Recommended)

1. Open Supabase Studio: `http://localhost:54323`
2. Go to Authentication → Users
3. Click "Add User" → "Create new user"
4. Enter email and password
5. User's profile will be auto-created via trigger
6. Manually update via SQL Editor:

```sql
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
```

```sql
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
```

```sql
-- After creating pending@motivaid.com
UPDATE profiles 
SET 
  full_name = 'Jane Pending',
  phone = '+234-803-456-7890'
WHERE email = 'pending@motivaid.com';

-- DON'T create unit_membership - this user should be pending!
```

### Option 2: Via App Signup

1. Run app: `flutter run -d chrome`
2. Go to signup screen
3. Register with any email/password
4. User will be in pending state
5. Login as supervisor to assign them

## Testing Workflows

### Test Supervisor Assignment
1. Login as `pending@motivaid.com` → See "Awaiting Assignment"
2. Logout
3. Login as `supervisor@motivaid.com`
4. Home → "Supervisor Tools" → "Pending User Approvals"
5. Assign Jane Pending to facility/unit/role
6. Logout
7. Login as `pending@motivaid.com` → Now has access! ✅

### Test Regular User Access
1. Login as `midwife@motivaid.com`
2. Should immediately access dashboard
3. No "Supervisor Tools" section (not a supervisor)

### Test Supervisor Tools
1. Login as `supervisor@motivaid.com`
2. See "Supervisor Tools" in home
3. Can view and assign pending users

## Current Seed Data

Already in database from migrations:

**Facilities:**
- General Hospital Lagos
- Community Health Center Abuja

**Units:**
- Maternity Ward (Lagos)
- Emergency Unit (Lagos)
- Maternity Ward (Abuja)
- Labour Room (Abuja)

**Roles:**
- `midwife` - Regular healthcare worker
- `supervisor` - Can assign users
- `admin` - Full system access
