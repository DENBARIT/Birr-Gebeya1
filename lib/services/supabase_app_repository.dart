import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAppRepository {
  final _client = Supabase.instance.client;

  Future<bool> profileExistsByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return false;

    final resp = await _client
        .from('profiles')
        .select('id')
        .ilike('email', normalizedEmail)
        .maybeSingle();
    return resp != null;
  }

  Future<bool> profileExistsByPhoneNumber(String phoneNumber) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty) return false;

    final resp = await _client
        .from('profiles')
        .select('id')
        .eq('phone_number', normalizedPhone)
        .maybeSingle();
    return resp != null;
  }

  /// Checks whether [email] is already registered in Supabase Auth (auth.users).
  ///
  /// Strategy: call [signInWithOtp] with [shouldCreateUser] = false.
  /// • If Supabase accepts it (no exception) → user exists in auth, OTP was sent.
  /// • If Supabase throws with a message containing "not found" or similar →
  ///   user does NOT exist in auth.
  ///
  /// We immediately return the result without the caller needing to look at
  /// the OTP screen — the user is blocked from proceeding.
  Future<bool> emailExistsInAuth(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return false;
    try {
      await _client.auth.signInWithOtp(
        email: normalizedEmail,
        shouldCreateUser: false,
      );
      // Supabase accepted it → user already exists.
      debugPrint('emailExistsInAuth: $normalizedEmail exists in auth');
      return true;
    } on AuthException catch (e) {
      debugPrint('emailExistsInAuth AuthException: ${e.message}');
      // Supabase says the user was not found → new user.
      return false;
    } catch (e) {
      debugPrint('emailExistsInAuth unexpected error: $e');
      // On any other error (network, etc.) assume not found to be safe.
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final resp = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp as Map);
  }

  Future<bool> saveProfile({
    required String userName,
    String? fullName,
    String? telebirrNumber,
    String? nationalId,
    String? region,
    String? email,
    String? phoneNumber,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final record = {
      'id': user.id,
      'username': userName,
      'full_name': fullName,
      'telebirr_number': telebirrNumber,
      'national_id': nationalId,
      'region': region,
      'email': email,
      'phone_number': phoneNumber,
    }..removeWhere((k, v) => v == null);

    try {
      await _client.from('profiles').upsert(record);
      return true;
    } catch (_) {
      return false;
    }
  }
}
