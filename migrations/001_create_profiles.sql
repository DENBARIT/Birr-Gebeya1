CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text NOT NULL,
  full_name text,
  telebirr_number text,
  email text,
  phone_number text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS profiles_email_key
  ON public.profiles (email)
  WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_phone_number_key
  ON public.profiles (phone_number)
  WHERE phone_number IS NOT NULL;

INSERT INTO public.profiles (id, username, full_name, telebirr_number, email, phone_number)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'alice', 'Alice Demo', '+251912345678', 'alice@example.com', '+251912345678'),
  ('00000000-0000-0000-0000-000000000002', 'bob', 'Bob Demo', '+251923456789', 'bob@example.com', '+251923456789')
ON CONFLICT (id) DO NOTHING;