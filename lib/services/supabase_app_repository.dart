import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAppRepository {
  final _client = Supabase.instance.client;

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
