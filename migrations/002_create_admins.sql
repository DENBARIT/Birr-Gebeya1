-- Migration to create admins table for Role-Based Access Control (KAN-29)
CREATE TABLE IF NOT EXISTS public.admins (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  role text NOT NULL DEFAULT 'admin' CHECK (role IN ('superadmin', 'admin', 'moderator')),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users so the app can verify roles
CREATE POLICY "Allow public read of admin roles"
  ON public.admins
  FOR SELECT
  TO authenticated
  USING (true);

-- Insert demo admin placeholder comments:
-- In your Supabase dashboard, insert the user's Auth UUID to make them an admin:
-- INSERT INTO public.admins (id, email, role) VALUES ('<USER-UUID>', 'admin@birrgebeya.com', 'superadmin');
