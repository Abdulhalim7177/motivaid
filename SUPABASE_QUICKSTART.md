# Quick Start: Supabase Local Development

## 1. Start Local Supabase

```bash
supabase start
```

**Save the credentials from the output:**
- API URL: `http://localhost:54321`
- anon key: (displayed in terminal)
- service_role key: (displayed in terminal)

## 2. Update Flutter App

Edit `lib/main.dart` and change:

```dart
await Supabase.initialize(
  url: 'http://localhost:54321',  // ← Change to local
  anonKey: 'YOUR_LOCAL_ANON_KEY', // ← Use key from step 1
);
```

## 3. Run Your App

```bash
flutter run -d chrome --web-port=8080
# or
flutter run -d <your-device>
```

## 4. Test

- Sign up a new user
- Check profile was created: `http://localhost:54323` (Supabase Studio)
- Edit profile in your app
- Verify changes in Studio

## 5. Stop

```bash
supabase stop
```

---

## Migrations Included

✅ `20260127000001_create_profiles_table.sql` - Profiles table + RLS
✅ `20260127000002_add_updated_at_trigger.sql` - Auto timestamp updates

These are automatically applied on `supabase start`.

---

See `supabase/LOCAL_DEVELOPMENT.md` for full documentation.
