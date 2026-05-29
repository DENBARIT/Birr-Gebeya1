import 'dart:io';

import 'package:flutter/foundation.dart';
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
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.sendEmailSignupOtp: email=$email');
      final res = await _client.auth.signUp(email: email, password: password);
      debugPrint('sendEmailSignupOtp response: ${res.toString()}');
    } on SocketException catch (e, st) {
      _logNetworkError('sendEmailSignupOtp', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('sendEmailSignupOtp error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Verifies the e-mailed sign-up code. Throws [AuthException] on a bad/expired
  /// code. On success a session is created.
  Future<AuthResponse> verifyEmailSignup({
    required String email,
    required String token,
  }) {
    debugPrint(
      'AuthService.verifyEmailSignup: email=$email tokenLen=${token.length}',
    );
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<void> resendEmailSignupOtp({required String email}) async {
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.resendEmailSignupOtp: email=$email');
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on SocketException catch (e, st) {
      _logNetworkError('resendEmailSignupOtp', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('resendEmailSignupOtp error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign in (e-mail + password). Only succeeds once the e-mail is confirmed.
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    debugPrint('AuthService.signInWithPassword: email=$email');
    return _withNetworkGuard(
      'signInWithPassword',
      () => _client.auth.signInWithPassword(email: email, password: password),
    );
  }

  // ---------------------------------------------------------------------------
  // Phone OTP (passwordless). Requires an SMS provider configured in Supabase.
  // ---------------------------------------------------------------------------
  Future<void> sendSmsOtp({required String phone}) async {
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.sendSmsOtp: phone=$phone');
      await _client.auth.signInWithOtp(phone: phone);
    } on SocketException catch (e, st) {
      _logNetworkError('sendSmsOtp', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('sendSmsOtp error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<AuthResponse> verifySmsOtp({
    required String phone,
    required String token,
  }) {
    debugPrint(
      'AuthService.verifySmsOtp: phone=$phone tokenLen=${token.length}',
    );
    return _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> resendSmsOtp({required String phone}) async {
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.resendSmsOtp: phone=$phone');
      await _client.auth.signInWithOtp(phone: phone);
    } on SocketException catch (e, st) {
      _logNetworkError('resendSmsOtp', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('resendSmsOtp error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset: e-mail a recovery code, verify it (creates a session), then
  // set the new password.
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.sendPasswordResetOtp: email=$email');
      await _client.auth.resetPasswordForEmail(email);
    } on SocketException catch (e, st) {
      _logNetworkError('sendPasswordResetOtp', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('sendPasswordResetOtp error: $e');
      debugPrint('$st');
      rethrow;
    }
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
    try {
      await _ensureNetworkForAuth();
      debugPrint('AuthService.updatePassword');
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on SocketException catch (e, st) {
      _logNetworkError('updatePassword', e, st);
      rethrow;
    } catch (e, st) {
      debugPrint('updatePassword error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<T> _withNetworkGuard<T>(
    String action,
    Future<T> Function() run,
  ) async {
    try {
      await _ensureNetworkForAuth();
      return await run();
    } on SocketException catch (e, st) {
      _logNetworkError(action, e, st);
      rethrow;
    }
  }

  Future<void> _ensureNetworkForAuth() async {
    final host = Uri.parse(_client.rest.url).host;
    try {
      await InternetAddress.lookup(host);
    } on SocketException catch (e) {
      throw SocketException(
        'Cannot reach Supabase host "$host". Check internet, VPN, Private DNS, or ad-blocking DNS. Original error: $e',
      );
    }
  }

  void _logNetworkError(String action, SocketException error, StackTrace st) {
    debugPrint('$action network error: $error');
    debugPrint('$st');
  }
}
