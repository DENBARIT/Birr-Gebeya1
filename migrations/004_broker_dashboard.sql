-- Broker dashboard: CSD account provisioning, order routing, SMS verification.
--
-- Adds the CSD/KYC columns the broker dashboard reads and writes on
-- `profiles`, a `brokers` allow-list table (broker staff are not customer
-- profiles and shouldn't share that trust boundary), an `orders` table the
-- mobile app writes to when a user buys an asset, and a
-- `broker_sms_messages` table logging the verification SMS a broker pastes
-- in (or a future gateway posts in) so it can be matched against an order.

-- ---------------------------------------------------------------------
-- profiles: CSD account + the KYC fields the app already collects on the
-- KYC screen (gender, date of birth) but has never actually persisted.
-- ---------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS csd_account_number text;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS csd_account_status text NOT NULL DEFAULT 'pending';

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_csd_account_status_check
  CHECK (csd_account_status IN ('pending', 'active'));

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS gender text;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS date_of_birth date;

-- Security: migration 001's "own profile update" RLS policy lets a signed-in
-- user update every column on their own row, which would otherwise let them
-- set their own csd_account_number/csd_account_status directly via the
-- client SDK and bypass the broker entirely. Column-level REVOKE closes
-- that regardless of RLS, while the broker dashboard's service_role client
-- (which bypasses grants the same way it bypasses RLS) is unaffected.
REVOKE UPDATE (csd_account_number, csd_account_status)
  ON public.profiles FROM authenticated;

-- ---------------------------------------------------------------------
-- brokers: allow-list of broker staff accounts. Separate from `profiles`
-- (customer identity) — existence of a row here, keyed by the Supabase
-- auth user id, is what the broker dashboard's requireBroker() checks.
-- Provisioned manually (Supabase SQL/dashboard), not via self-signup.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.brokers (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text,
  email text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.brokers ENABLE ROW LEVEL SECURITY;
-- Deliberately no policies for authenticated/anon — only the broker
-- dashboard's service-role client (which bypasses RLS) reads/writes this,
-- same as how admin-dashboard treats the is_admin flag.

-- ---------------------------------------------------------------------
-- orders: one row per "buy" the mobile app submits. Snapshots
-- asset/amount/CSD-number/buyer-name at order time so SMS matching and the
-- broker's audit trail don't shift if the profile changes later.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  pool_id text NOT NULL,
  asset_name text NOT NULL,
  amount numeric(14, 2) NOT NULL,
  csd_account_number text NOT NULL,
  user_full_name text NOT NULL,
  status text NOT NULL DEFAULT 'pending_verification',
  created_at timestamptz NOT NULL DEFAULT now(),
  verified_at timestamptz,
  verified_by uuid REFERENCES public.brokers(id)
);

ALTER TABLE public.orders
  ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending_verification', 'verified', 'rejected', 'placed'));

CREATE INDEX IF NOT EXISTS orders_user_id_idx ON public.orders (user_id);
CREATE INDEX IF NOT EXISTS orders_status_idx ON public.orders (status);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- A user may see and create their own orders (same trust level as the rest
-- of this client-driven app today), but there is deliberately no
-- UPDATE/DELETE policy — only the broker dashboard's service-role client
-- can move an order out of pending_verification.
DROP POLICY IF EXISTS "own orders select" ON public.orders;
CREATE POLICY "own orders select" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "own orders insert" ON public.orders;
CREATE POLICY "own orders insert" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- broker_sms_messages: log of every verification SMS a broker pastes in
-- (or, later, a gateway webhook posts in), plus the result of matching it
-- against pending orders.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.broker_sms_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  broker_id uuid REFERENCES public.brokers(id),
  raw_text text NOT NULL,
  parsed_amount numeric(14, 2),
  parsed_user_name text,
  parsed_asset_name text,
  matched_order_id uuid REFERENCES public.orders(id),
  match_result text NOT NULL DEFAULT 'unmatched',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.broker_sms_messages
  ADD CONSTRAINT broker_sms_messages_match_result_check
  CHECK (match_result IN ('unmatched', 'matched', 'mismatched'));

CREATE INDEX IF NOT EXISTS broker_sms_messages_matched_order_id_idx
  ON public.broker_sms_messages (matched_order_id);

ALTER TABLE public.broker_sms_messages ENABLE ROW LEVEL SECURITY;
-- No policies — service-role only, same as notifications' write side.
