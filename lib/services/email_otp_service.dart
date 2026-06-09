import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result returned after dispatching an OTP via Supabase Auth.
class OtpDispatchResult {
  final String email;
  final String purpose;
  final String message;

  /// Always false — Supabase handles delivery via your configured SMTP.
  final bool isDemoMode;

  /// Always null — the code is never exposed to the client.
  final String? demoOtp;

  const OtpDispatchResult({
    required this.email,
    required this.purpose,
    required this.message,
    this.isDemoMode = false,
    this.demoOtp,
  });
}

/// Handles e-mail OTP dispatch and verification using **Supabase Auth**.
///
/// ### Sending
/// Calls [SupabaseClient.auth.signInWithOtp] — Supabase generates the 6-digit
/// code and delivers it via the SMTP settings you configured in your Supabase
/// project (Authentication → Settings → SMTP).
///
/// ### Verifying
/// Calls [SupabaseClient.auth.verifyOTP] with [OtpType.email].  On success
/// Supabase creates a session, so `auth.currentUser` is available immediately.
class EmailOtpService {
  EmailOtpService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Sends a 6-digit OTP to [email] through Supabase's configured SMTP.
  ///
  /// Set [shouldCreateUser] to `true` (default) for sign-up so that Supabase
  /// creates the user row if it doesn't exist yet.
  Future<OtpDispatchResult> sendOtpEmail({
    required String email,
    required String purpose,
    bool shouldCreateUser = true,
  }) async {
    final normalizedEmail = email.trim();
    debugPrint(
      'EmailOtpService.sendOtpEmail: email=$normalizedEmail purpose=$purpose',
    );

    try {
      await _client.auth.signInWithOtp(
        email: normalizedEmail,
        shouldCreateUser: shouldCreateUser,
      );
      debugPrint('EmailOtpService: OTP sent successfully via Supabase SMTP');
      return OtpDispatchResult(
        email: normalizedEmail,
        purpose: purpose,
        message: 'Verification code sent to $normalizedEmail.',
        isDemoMode: false,
      );
    } on AuthException catch (e, st) {
      debugPrint('EmailOtpService: AuthException sending OTP: $e\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('EmailOtpService: unexpected error sending OTP: $e\n$st');
      rethrow;
    }
  }

  /// Verifies [otp] against Supabase Auth for [email].
  ///
  /// Returns `true` on success (a session is now active).
  /// Returns `false` on an invalid/expired code.
  Future<bool> verifyOtp({
    required String email,
    required String purpose,
    required String otp,
  }) async {
    final normalizedEmail = email.trim();
    debugPrint(
      'EmailOtpService.verifyOtp: email=$normalizedEmail purpose=$purpose',
    );

    try {
      await _client.auth.verifyOTP(
        email: normalizedEmail,
        token: otp,
        type: OtpType.email,
      );
      debugPrint('EmailOtpService: OTP verified — session created');
      return true;
    } on AuthException catch (e, st) {
      debugPrint('EmailOtpService: OTP verification failed: $e\n$st');
      return false;
    } catch (e, st) {
      debugPrint('EmailOtpService: unexpected error verifying OTP: $e\n$st');
      return false;
    }
  }
}