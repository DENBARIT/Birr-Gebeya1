CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  -- NULL = broadcast to every user; otherwise visible only to that user.
  target_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_target_user_id_idx
  ON public.notifications (target_user_id);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Regular users may only read broadcasts and notifications addressed to
-- them. There is deliberately no insert/update/delete policy for the
-- `authenticated` role — only the admin dashboard's service-role client
-- (which bypasses RLS) can write, so a user can never notify themselves or
-- anyone else.
DROP POLICY IF EXISTS "read own or broadcast notifications" ON public.notifications;
CREATE POLICY "read own or broadcast notifications" ON public.notifications
  FOR SELECT USING (target_user_id IS NULL OR target_user_id = auth.uid());
