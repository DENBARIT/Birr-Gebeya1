import 'package:supabase/supabase.dart';

/// One-off diagnostic: exercises the exact same call the app makes on
/// sign-up (auth.signUp) against a fresh, never-before-used e-mail address,
/// and prints whatever Supabase actually returns — success, or the real
/// AuthException (status code + message) if the send still fails.
Future<void> main() async {
  const supabaseUrl = 'https://clcnvcfahmvaontnnpfc.supabase.co';
  const supabaseKey = 'sb_publishable_5ZumIK_AEUzPTJtAu5oQyg_fpBaY9Rc';

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  // Gmail "+" alias: delivers to the same real inbox (leulethiopia05@gmail.com)
  // while being a distinct, never-registered address as far as Supabase is
  // concerned — so this exercises a genuine fresh sign-up, not an
  // "already registered" path.
  final testEmail =
      'leulethiopia05+test${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  const testPassword = 'TestPassword123!';

  print('Testing signUp for: $testEmail');
  try {
    final res = await client.auth.signUp(
      email: testEmail,
      password: testPassword,
    );
    print('RESULT: signUp call succeeded (no exception).');
    print('  user id: ${res.user?.id}');
    print('  confirmed_at: ${res.user?.confirmedAt}');
    print(
      '  -> Supabase accepted the request. If SMTP is healthy, a real '
      'confirmation e-mail with a 6-digit code should now be in that inbox.',
    );
  } on AuthException catch (e) {
    print('RESULT: AuthException');
    print('  statusCode: ${e.statusCode}');
    print('  message: ${e.message}');
  } catch (e, st) {
    print('RESULT: unexpected error');
    print('  $e');
    print(st);
  }

  print('');
  print('Testing resetPasswordForEmail for: leulethiopia05@gmail.com');
  try {
    await client.auth.resetPasswordForEmail('leulethiopia05@gmail.com');
    print('RESULT: resetPasswordForEmail call succeeded (no exception).');
  } on AuthException catch (e) {
    print('RESULT: AuthException');
    print('  statusCode: ${e.statusCode}');
    print('  message: ${e.message}');
  } catch (e, st) {
    print('RESULT: unexpected error');
    print('  $e');
    print(st);
  }
}
