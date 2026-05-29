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
    String? telebirrNumber,
    String? email,
    String? phoneNumber,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final record = {
      'id': user.id,
      'username': userName,
      'telebirr_number': telebirrNumber,
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
