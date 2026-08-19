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
    String? fullName,
    String? telebirrNumber,
    String? nationalId,
    String? region,
    String? gender,
    DateTime? dateOfBirth,
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
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
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

  /// Creates an order the broker dashboard will see and verify against the
  /// SMS the broker receives — see
  /// birr_gebeya/migrations/004_broker_dashboard.sql. RLS lets a signed-in
  /// user insert only their own order row.
  Future<bool> createOrder({
    required String poolId,
    required String assetName,
    required double amount,
    required String csdAccountNumber,
    required String userFullName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      await _client.from('orders').insert({
        'user_id': user.id,
        'pool_id': poolId,
        'asset_name': assetName,
        'amount': amount,
        'csd_account_number': csdAccountNumber,
        'user_full_name': userFullName,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetches notifications visible to the signed-in user: admin broadcasts
  /// (target_user_id IS NULL) plus anything addressed to them specifically.
  /// Row Level Security enforces that filter server-side — see
  /// migrations/003_create_notifications.sql — so no extra `.eq()` is needed
  /// here; an unauthenticated caller simply gets an empty list.
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final resp = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(resp as List);
  }
}
