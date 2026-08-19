-- Adds an admin flag used by the web admin dashboard to gate access.
-- Not exposed anywhere in the mobile app; only the dashboard's
-- service-role-backed server code reads/writes it.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;

-- Also backfill the columns the app already writes via
-- SupabaseAppRepository.saveProfile() (national_id, region) in case this
-- environment doesn't have them yet — 001_create_profiles.sql predates them.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS national_id text;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS region text;
