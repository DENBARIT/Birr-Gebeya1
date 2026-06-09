import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result returned after attempting to dispatch an OTP to the user's e-mail.
///
/// [isDemoMode] is always false when using the Supabase-native flow — the
/// code is generated and delivered entirely by Supabase via your configured
/// SMTP provider.
class OtpDispatchResult {
  final String email;
  final String purpose;
  final String message;

  /// Always false in the Supabase-native flow. Kept for API compatibility.
  final bool isDemoMode;

  /// Always null in the Supabase-native flow.
  final String? demoOtp;

  const OtpDispatchResult({
    required this.email,
    required this.purpose,
    required this.message,
    this.isDemoMode = false,
    this.demoOtp,
  });
}

/// Handles e-mail OTP dispatch and verification via **Supabase Auth**.
///
/// Sending:
///   Uses [SupabaseClient.auth.signInWithOtp] which triggers Supabase to send
///   a 6-digit code through your project's configured SMTP provider.
///
/// Verifying:
///   Uses [SupabaseClient.auth.verifyOTP] with [OtpType.email] to validate the
///   code entered by the user and establish a session.
class EmailOtpService {
  EmailOtpService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Sends a 6-digit OTP to [email] via Supabase Auth (SMTP).
  ///
  /// [shouldCreateUser] controls whether Supabase creates a new user row if the
  /// e-mail is not yet registered (defaults to true for the sign-up flow).
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
      debugPrint('EmailOtpService: OTP email sent via Supabase SMTP');
      return OtpDispatchResult(
        email: normalizedEmail,
        purpose: purpose,
        message: 'Verification code sent to $normalizedEmail.',
        isDemoMode: false,
      );
    } on AuthException catch (e, st) {
      debugPrint('EmailOtpService: AuthException sending OTP: $e');
      debugPrint('$st');
      rethrow;
    } catch (e, st) {
      debugPrint('EmailOtpService: unexpected error sending OTP: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Verifies the 6-digit [otp] code for [email] using Supabase Auth.
  ///
  /// Returns `true` and establishes a Supabase session on success.
  /// Throws [AuthException] if the code is invalid or expired.
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
      debugPrint('EmailOtpService: OTP verified successfully');
      return true;
    } on AuthException catch (e, st) {
      debugPrint('EmailOtpService: OTP verification failed: $e');
      debugPrint('$st');
      return false;
    } catch (e, st) {
      debugPrint('EmailOtpService: unexpected error verifying OTP: $e');
      debugPrint('$st');
      return false;
    }
  }
}