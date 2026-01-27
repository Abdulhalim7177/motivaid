# Supabase Database Setup Instructions

## Problem
You're getting the error: **"Database error saving new user"** because the Supabase database doesn't have a profiles table set up yet.

## Solution
Follow these steps to set up the database:

### Step 1: Open Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project: **jkzpaahnypxhpwjkncsm**

### Step 2: Run the SQL Migration
1. In the left sidebar, click on **SQL Editor**
2. Click **New Query**
3. Copy the entire contents of the file `supabase_setup.sql` (located in your project root)
4. Paste it into the SQL Editor
5. Click **Run** (or press Ctrl+Enter)

### Step 3: Verify the Setup
After running the SQL:
1. Go to **Table Editor** in the left sidebar
2. You should see a new table called **profiles**
3. The table should have these columns:
   - `id` (uuid, primary key)
   - `email` (text)
   - `created_at` (timestamp)
   - `updated_at` (timestamp)

### Step 4: Test Sign-Up Again
1. Go back to your app at `http://localhost:8080`
2. Click **Sign Up**
3. Fill in the form:
   - Email: `abdulmuhd7177@gmail.com`
   - Password: `password`
   - Confirm Password: `password`
4. Click **Sign Up**
5. You should now be successfully registered and logged in!

---

## What This Does

The SQL script:
- ✅ Creates a `profiles` table to store user data
- ✅ Sets up Row Level Security (RLS) policies so users can only access their own data
- ✅ Creates a database trigger that automatically creates a profile entry when a new user signs up
- ✅ Links the profiles table to Supabase's auth.users table

## Alternative: Quick Copy-Paste SQL

If you prefer, here's the SQL to copy directly:

```sql
-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email) VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## After Setup

Once you've run the SQL:
1. Your sign-up should work without errors
2. Each new user will automatically get a profile entry
3. Users can only access their own profile data (RLS protection)
