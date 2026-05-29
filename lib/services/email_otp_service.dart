import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpDispatchResult {
  final String email;
  final String purpose;
  final String message;
  final bool isDemoMode;
  final String? demoOtp;

  const OtpDispatchResult({
    required this.email,
    required this.purpose,
    required this.message,
    required this.isDemoMode,
    this.demoOtp,
  });
}

class EmailOtpService {
  EmailOtpService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static final Map<String, String> _demoOtpCache = <String, String>{};

  final SupabaseClient _client;

  String _cacheKey({required String email, required String purpose}) {
    return '${purpose.trim().toLowerCase()}|${email.trim().toLowerCase()}';
  }

  String _generateOtp() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<OtpDispatchResult> sendOtpEmail({
    required String email,
    required String purpose,
  }) async {
    final normalizedEmail = email.trim();
    final otp = _generateOtp();
    final functionName = dotenv.env['OTP_EMAIL_FUNCTION_NAME']?.trim();

    if (functionName != null && functionName.isNotEmpty) {
      try {
        await _client.functions.invoke(
          functionName,
          body: <String, dynamic>{
            'email': normalizedEmail,
            'otp': otp,
            'purpose': purpose,
          },
        );

        _demoOtpCache.remove(
          _cacheKey(email: normalizedEmail, purpose: purpose),
        );
        return OtpDispatchResult(
          email: normalizedEmail,
          purpose: purpose,
          message: 'Verification code sent to $normalizedEmail.',
          isDemoMode: false,
        );
      } catch (_) {
        // Fall back to local demo mode if the backend function is not available yet.
      }
    }

    if (functionName == null || functionName.isEmpty) {
      _demoOtpCache[_cacheKey(email: normalizedEmail, purpose: purpose)] = otp;
      return OtpDispatchResult(
        email: normalizedEmail,
        purpose: purpose,
        message:
            'Email backend is not configured, so a demo code was generated locally.',
        isDemoMode: true,
        demoOtp: otp,
      );
    }

    _demoOtpCache[_cacheKey(email: normalizedEmail, purpose: purpose)] = otp;
    return OtpDispatchResult(
      email: normalizedEmail,
      purpose: purpose,
      message: 'Demo verification code generated for $normalizedEmail.',
      isDemoMode: true,
      demoOtp: otp,
    );
  }

  Future<bool> verifyOtp({
    required String email,
    required String purpose,
    required String otp,
  }) async {
    final normalizedEmail = email.trim();
    final functionName = dotenv.env['OTP_VERIFY_FUNCTION_NAME']?.trim();

    if (functionName != null && functionName.isNotEmpty) {
      try {
        final response = await _client.functions.invoke(
          functionName,
          body: <String, dynamic>{
            'email': normalizedEmail,
            'otp': otp,
            'purpose': purpose,
          },
        );

        final data = response.data;
        if (data is Map && data['valid'] is bool) {
          return data['valid'] as bool;
        }
        return true;
      } catch (_) {
        return false;
      }
    }

    final cachedOtp =
        _demoOtpCache[_cacheKey(email: normalizedEmail, purpose: purpose)];
    return cachedOtp != null && cachedOtp == otp;
  }
}
