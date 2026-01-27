# Supabase Local Development Setup

This guide explains how to use Supabase locally for development.

## Prerequisites

- Supabase CLI installed (`npm install -g supabase` or see [Supabase CLI docs](https://supabase.com/docs/guides/cli))
- Docker Desktop running (required for local Supabase)

## Directory Structure

```
supabase/
├── config.toml              # Supabase configuration
└── migrations/              # Database migrations
    ├── 20260127000001_create_profiles_table.sql
    └── 20260127000002_add_updated_at_trigger.sql
```

## Setup Steps

### 1. Start Supabase Locally

```bash
supabase start
```

This will:
- Start Docker containers for PostgreSQL, Auth, Storage, etc.
- Apply all migrations in `supabase/migrations/`
- Display your local credentials

**Save the output** - you'll need:
- API URL (usually `http://localhost:54321`)
- `anon key`
- `service_role key`

### 2. Update Flutter App Configuration

Update your Supabase credentials in the app to use local instance:

**Option A: Hardcode for Development** (in `lib/main.dart`):
```dart
await Supabase.initialize(
  url: 'http://localhost:54321',  // Local Supabase URL
  anonKey: 'YOUR_LOCAL_ANON_KEY', // From supabase start output
);
```

**Option B: Use Environment Variables** (recommended):
1. Create `.env` file:
   ```
   SUPABASE_URL=http://localhost:54321
   SUPABASE_ANON_KEY=your_local_anon_key
   ```
2. Add `flutter_dotenv` to `pubspec.yaml`
3. Load in `main.dart`

### 3. Verify Migrations

Check if migrations were applied:

```bash
supabase db diff
```

Or open Studio:
```bash
supabase studio
```

This opens a local dashboard at `http://localhost:54323`.

### 4. Create a Test User

You can create test users via:

**Option A: Studio UI**
1. Open `http://localhost:54323`
2. Go to Authentication → Users
3. Add User

**Option B: Your Flutter App**
- Just use the signup screen as normal

### 5. Stop Supabase

When done developing:

```bash
supabase stop
```

To clear all data and reset:
```bash
supabase db reset
```

## Migrations

### Creating New Migrations

```bash
supabase migration new migration_name
```

This creates a new timestamped SQL file in `supabase/migrations/`.

### Our Current Migrations

1. **`20260127000001_create_profiles_table.sql`**
   - Creates `profiles` table
   - Sets up Row Level Security (RLS)
   - Creates trigger for auto-profile creation on signup
   - Adds indexes

2. **`20260127000002_add_updated_at_trigger.sql`**
   - Auto-updates `updated_at` field on profile changes

### Applying New Migrations

Migrations are automatically applied when you:
- Run `supabase start` (for the first time)
- Run `supabase db reset` (resets and reapplies all)
- Run `supabase migration up` (applies pending migrations)

## Switching Between Local and Production

### For Development → Use Local
```dart
url: 'http://localhost:54321',
anonKey: 'local_anon_key',
```

### For Production → Use Hosted Supabase
```dart
url: 'https://jkzpaahnypxhpwjkncsm.supabase.co',
anonKey: 'your_production_anon_key',
```

**Best Practice**: Use environment variables or build flavors to switch automatically.

## Useful Commands

```bash
# Start local Supabase
supabase start

# Stop local Supabase
supabase stop

# Reset database (clears all data, reapplies migrations)
supabase db reset

# Open Studio dashboard
supabase studio

# Check migration status
supabase migration list

# Create new migration
supabase migration new your_migration_name

# Generate types for TypeScript/Dart
supabase gen types typescript --local

# Push local migrations to remote
supabase db push

# Pull remote schema to local
supabase db pull
```

## Testing

After starting local Supabase:

1. **Run your Flutter app** pointing to `http://localhost:54321`
2. **Sign up** - should auto-create profile
3. **Check Studio** - verify profile was created in `profiles` table
4. **Edit profile** - test RLS policies work

## Troubleshooting

**Migration errors on start:**
```bash
supabase db reset
supabase start
```

**Can't connect from Flutter:**
- Ensure Docker is running
- Check `http://localhost:54321` is accessible
- Verify anon key is correct

**RLS blocking operations:**
- Check you're authenticated
- Verify RLS policies in Studio → Database → Policies

## Production Deployment

When ready to deploy to production:

1. **Link to your project:**
   ```bash
   supabase link --project-ref your-project-ref
   ```

2. **Push migrations:**
   ```bash
   supabase db push
   ```

This applies all local migrations to your production database.

## Next Steps

- Start adding more migrations for app features
- Use `supabase db diff` to generate migrations from schema changes
- Test everything locally before pushing to production
