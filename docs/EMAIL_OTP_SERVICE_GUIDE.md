# Email / OTP Service — Reusable Guide

How this app sends and verifies e-mail one-time codes (sign-up, sign-in, password
reset), and how to port the same flow into another Flutter + Supabase app.

## 1. Architecture in one paragraph

There is **no custom backend and no direct SMTP call from the app**. All e-mail
delivery and OTP verification is delegated to **Supabase Auth**. The app calls
`supabase_flutter`'s `auth.signUp` / `auth.signInWithOtp` / `auth.verifyOTP` /
`auth.resetPasswordForEmail` / `auth.resend`. Supabase generates the 6-digit
code, e-mails it using the SMTP server configured in the Supabase dashboard, and
verifies it server-side. On successful verification Supabase creates a real
session (`auth.currentUser` becomes available). The app never generates,
stores, or sees the code itself.

```
Flutter app  ──auth.signUp/signInWithOtp──▶  Supabase Auth  ──SMTP──▶  User's inbox
Flutter app  ◀────────session/token──────── Supabase Auth  ◀──user enters code──
```

## 2. Files involved in this project

| File | Role |
|---|---|
| [`lib/services/auth_service.dart`](../lib/services/auth_service.dart) | **The real, wired-in service.** Thin wrapper around `SupabaseClient.auth` for signup OTP, password-reset OTP, phone OTP, sign-in, sign-out. Screens call this. |
| [`lib/screens/phone_auth_screen.dart`](../lib/screens/phone_auth_screen.dart) | Sign up / sign in / "forgot password" form. Decides email vs. phone, calls `AuthService`, then pushes `OtpVerificationScreen`. |
| [`lib/screens/otp_verification_screen.dart`](../lib/screens/otp_verification_screen.dart) | Generic 6-digit code entry UI. Takes `onVerifyOtp` / `onResendOtp` callbacks (or falls back to calling `AuthService` directly based on an `OtpPurpose` enum). Has a resend cooldown timer. |
| [`lib/services/supabase_app_repository.dart`](../lib/services/supabase_app_repository.dart) | Not e-mail delivery itself, but the pre-signup checks: `profileExistsByEmail` (queries the `profiles` table) and `emailExistsInAuth` (probes `auth.users` via a `shouldCreateUser: false` OTP call) so the UI can show "account already exists" instead of erroring. |
| [`lib/main.dart`](../lib/main.dart) | Loads `.env` via `flutter_dotenv` and calls `Supabase.initialize(url, anonKey)` before anything else runs. |
| [`migrations/001_create_profiles.sql`](../migrations/001_create_profiles.sql) | `profiles` table with a unique, partial index on `email` (and `phone_number`), RLS locked to `auth.uid()`. |
| `.env` (not committed conceptually — see §6) | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and (optional/legacy) raw SMTP vars — see §5. |

### Dead code / do NOT copy as-is

- **`lib/services/email_otp_service.dart`** — a duplicate wrapper around
  `signInWithOtp` / `verifyOTP`. It is **not referenced anywhere** in the app;
  `AuthService` is what's actually used. Skip it, or use it only as a simpler
  reference implementation.
- **`tool/test_complete_signup.dart`** — a one-off manual test script that
  sends mail directly via Gmail SMTP using the `mailer` package. `mailer` is
  **not even in `pubspec.yaml`** — this script doesn't compile as part of the
  app. It predates the switch to letting Supabase handle delivery entirely.
  Don't port this pattern; it's a dead end.
- **`OTP_EMAIL_FUNCTION_NAME` / `OTP_VERIFY_FUNCTION_NAME`** in `.env` — commented-out
  placeholders for a hypothetical Supabase Edge Function approach. No such
  functions exist in this repo (no `supabase/functions` directory). Ignore
  unless you build that yourself.

## 3. The four flows, step by step

### A. Sign up (email + password)
1. `AuthService.sendEmailSignupOtp(email, password)` → `auth.signUp(email, password)`.
   Supabase creates an *unconfirmed* user and e-mails a 6-digit code using the
   **"Confirm signup"** template.
2. User enters the code → `AuthService.verifyEmailSignup(email, token)` →
   `auth.verifyOTP(email, token, type: OtpType.signup)`. On success this
   returns an `AuthResponse` with a non-null `session`.
3. Resend: `AuthService.resendEmailSignupOtp(email)` → `auth.resend(type: OtpType.signup, email)`.

### B. Sign in (email + password, no OTP)
- `AuthService.signInWithPassword(email, password)` → `auth.signInWithPassword(...)`.
  Only succeeds once the e-mail has been confirmed via flow A.

### C. Password reset
1. `AuthService.sendPasswordResetOtp(email, redirectTo)` → `auth.resetPasswordForEmail(...)`.
   Sends a 6-digit code via the **"Reset password"** template.
   (`redirectTo` is only relevant for the magic-link variant on web; for the
   OTP-in-app flow it can be left `null` on mobile.)
2. `AuthService.verifyPasswordReset(email, token)` → `auth.verifyOTP(email, token, type: OtpType.recovery)`
   → creates a session.
3. `AuthService.updatePassword(newPassword)` → `auth.updateUser(UserAttributes(password: ...))`.
4. `AuthService.signOut()` so the user re-authenticates with the new password.

### D. Phone OTP (SMS, not e-mail — included for completeness)
`sendSmsOtp` / `verifySmsOtp` / `resendSmsOtp` mirror the same pattern with
`OtpType.sms`. Requires an SMS provider configured in Supabase; unrelated to
e-mail delivery.

### Pre-signup existence check (avoids a confusing duplicate-signup error)
Before starting flow A, the UI calls, in order:
1. `SupabaseAppRepository.profileExistsByEmail(email)` — checks the app's own
   `profiles` table (covers users who finished onboarding).
2. If that's false, `SupabaseAppRepository.emailExistsInAuth(email)` — calls
   `signInWithOtp(email, shouldCreateUser: false)`; Supabase accepting it means
   the address is already registered in `auth.users` (covers users who
   verified but never finished onboarding).

If either is true, the UI shows an "Account already exists" dialog with
shortcuts to Sign In / Reset Password instead of calling `signUp` again.

## 4. Porting this into a new app — checklist

1. **Supabase project**: create one (or reuse), get the Project URL and
   `anon`/publishable key.
2. **Enable email OTP as a 6-digit code, not a magic link**: Dashboard →
   Authentication → Email Templates → edit "Confirm signup" and "Reset
   password" templates to reference `{{ .Token }}` (the 6-digit code) instead
   of `{{ .ConfirmationURL }}`. This is the detail people most often miss —
   without it, Supabase e-mails a clickable link and `verifyOTP` has nothing
   to check against.
3. **Configure SMTP**: Dashboard → Authentication → Settings → SMTP Settings.
   Supabase's default mailer is rate-limited and fine for dev; for production
   plug in your own SMTP (Gmail app password, SendGrid, Postmark, etc.) here —
   **not** in your app's code.
4. **Dependencies** (`pubspec.yaml`):
   ```yaml
   dependencies:
     supabase_flutter: ^1.5.0   # or ^2.x — check current API before copying 1:1
     flutter_dotenv: ^5.1.0
   flutter:
     assets:
       - .env
   ```
   Note: this project pins `supabase_flutter: ^1.5.0`. If the target app uses
   v2, re-check method signatures (`OtpType`, `AuthResponse`, `signInWithOtp`
   parameters) against that version's docs before copy-pasting.
5. **`.env`**:
   ```
   SUPABASE_URL=https://<project-ref>.supabase.co
   SUPABASE_ANON_KEY=<publishable/anon key>
   ```
6. **Init** (`main.dart`, before `runApp`):
   ```dart
   await dotenv.load();
   await Supabase.initialize(
     url: dotenv.env['SUPABASE_URL']!,
     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
   );
   ```
7. **Copy** `lib/services/auth_service.dart` as-is (it has no dependency on
   this app's UI/theme — only on `supabase_flutter`). Rename/trim methods you
   don't need (e.g. drop the phone-OTP methods for an email-only app).
8. **Copy** `lib/screens/otp_verification_screen.dart` as a starting point for
   the code-entry UI; it depends on this project's `BirrTheme` design system
   and a `dotenv.env['TEST_OTP_EMAIL']` dev fallback — swap those for the new
   app's theme and delete the dev fallback.
9. **If you also need "does this email already exist" pre-checks**, copy the
   two methods from `supabase_app_repository.dart` and adjust the table name.
10. **Table + RLS**: if you store profile data, adapt
    `migrations/001_create_profiles.sql` — the key pattern to keep is the
    partial unique index (`WHERE email IS NOT NULL`) and RLS policies keyed on
    `auth.uid() = id`.

## 5. Legacy/manual SMTP env vars (not currently used by app code)

`.env` in this project also carries these, left over from an earlier
direct-SMTP experiment (`tool/test_complete_signup.dart`) and **not read by
any code under `lib/`**:

```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=<gmail address>
EMAIL_PASS=<gmail app password>
EMAIL_FROM="Your App <gmail address>"
```

Only relevant if you deliberately want to send mail yourself (e.g. from a
Dart CLI tool or a Supabase Edge Function) instead of letting Supabase Auth's
built-in SMTP handle it. For the in-app OTP flow described above, ignore
these — configure SMTP in the Supabase dashboard instead (see §4.3).

## 6. Security notes

- The `.env` file in this project currently holds **live secrets in plaintext**
  (Supabase anon key, a Gmail app password, an xAI/Grok API key). The anon key
  is designed to be public-ish (RLS protects data), but the Gmail app password
  and Grok key are not — treat `.env` as sensitive, keep it out of version
  control (`.gitignore`), and if this folder is ever shared or pushed to a
  public repo, rotate the Gmail app password and the Grok key immediately.
- Never move SMTP credentials into client-side Dart code in a shipped app —
  they'd be extractable from the binary. Keep SMTP config server-side (Supabase
  dashboard, or an Edge Function using a service-role key), never in `.env`
  bundled as a Flutter asset for release builds.
- `verifyOTP` failures are caught and surfaced as generic "incorrect code"
  messages to the user (see `otp_verification_screen.dart`) rather than
  leaking Supabase's raw error — keep that pattern when porting.

## 7. Troubleshooting patterns worth keeping

- `AuthService._ensureNetworkForAuth()` does a DNS lookup (`InternetAddress.lookup`)
  against the Supabase host before auth calls, skipped on web (`kIsWeb`), so
  users get "check your internet/VPN/DNS" instead of an opaque socket error —
  useful for regions with flaky DNS or ad-blocker DNS interference.
- `OtpVerificationScreen` clears the 6 input boxes and refocuses the first one
  on any verification failure, and disables the resend button behind a 45s
  countdown to avoid hammering Supabase's rate limit.
