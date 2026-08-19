import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AdminRole { superAdmin, analyst, support }

enum AdminLoginResult { success, notFound, suspended, error }

class AdminAccount {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final bool isActive;

  AdminAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

/// Separate admin session, isolated from the regular user AppState/auth flow.
class AdminSession extends ChangeNotifier {
  AdminSession._internal();
  static final AdminSession instance = AdminSession._internal();

  AdminAccount? _current;
  AdminAccount? get current => _current;
  bool get isSignedIn => _current != null;

  // TEMPORARY dev bypass so you can demo before admin_accounts has real rows.
  // Disabled — a hardcoded credential compiled into a shipped app is a
  // standing backdoor regardless of whether admin_accounts has real rows
  // yet. Re-enable locally for testing only; never flip this back to true
  // in anything that gets built for a device or committed.
  static const bool _enableDevBypass = false;
  static const String _devEmail = 'admin@birrgebeya.com';
  static const String _devPassword = 'admin123';

  Future<AdminLoginResult> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (_enableDevBypass &&
        trimmedEmail == _devEmail &&
        password == _devPassword) {
      _current = AdminAccount(
        id: 'dev-bypass',
        name: 'Developer Admin',
        email: _devEmail,
        role: AdminRole.superAdmin,
        isActive: true,
      );
      notifyListeners();
      return AdminLoginResult.success;
    }

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('admin_accounts')
          .select()
          .eq('email', trimmedEmail)
          .maybeSingle();

      if (response == null) return AdminLoginResult.notFound;

      // NOTE: this compares plaintext for now. Before you ship, move this
      // check into a Supabase RPC function that verifies a bcrypt hash
      // server-side instead of comparing on the client.
      if (response['password_hash'] != password) {
        return AdminLoginResult.notFound;
      }

      if (response['is_active'] == false) return AdminLoginResult.suspended;

      _current = AdminAccount(
        id: response['id'].toString(),
        name: response['name'] as String? ?? 'Admin',
        email: response['email'] as String,
        role: AdminRole.values.firstWhere(
          (r) =>
              r.name.toLowerCase() ==
              (response['role'] as String).toLowerCase(),
          orElse: () => AdminRole.support,
        ),
        isActive: response['is_active'] as bool? ?? true,
      );
      notifyListeners();
      return AdminLoginResult.success;
    } catch (_) {
      return AdminLoginResult.error;
    }
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }
}
