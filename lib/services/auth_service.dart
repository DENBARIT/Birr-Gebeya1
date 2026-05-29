import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth for the e-mail / phone OTP flows used by
/// the sign-up, sign-in and password-reset screens.
///
/// All OTP codes are generated, delivered and verified by Supabase Auth — the
/// app never sees or fabricates the code. A successful [verifyEmailSignup] /
/// [verifySmsOtp] / [verifyPasswordReset] establishes a real session, after
/// which `auth.currentUser` is available and the `profiles` table (whose RLS
/// keys off `auth.uid()`) can be written.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => _client.auth.currentSession != null;

  // ---------------------------------------------------------------------------
  // Sign up (e-mail + password). Supabase sends a confirmation e-mail that
  // contains the 6-digit token ({{ .Token }} in the "Confirm signup" template).
  // ---------------------------------------------------------------------------
  Future<void> sendEmailSignupOtp({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  /// Verifies the e-mailed sign-up code. Throws [AuthException] on a bad/expired
  /// code. On success a session is created.
  Future<AuthResponse> verifyEmailSignup({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<void> resendEmailSignupOtp({required String email}) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  // ---------------------------------------------------------------------------
  // Sign in (e-mail + password). Only succeeds once the e-mail is confirmed.
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // ---------------------------------------------------------------------------
  // Phone OTP (passwordless). Requires an SMS provider configured in Supabase.
  // ---------------------------------------------------------------------------
  Future<void> sendSmsOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifySmsOtp({
    required String phone,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> resendSmsOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  // ---------------------------------------------------------------------------
  // Password reset: e-mail a recovery code, verify it (creates a session), then
  // set the new password.
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordResetOtp({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyPasswordReset({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _client.auth.signOut();
}
