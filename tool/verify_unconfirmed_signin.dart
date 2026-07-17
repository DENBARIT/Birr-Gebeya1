import 'package:supabase/supabase.dart';

/// Tests whether an account can sign in with a password BEFORE its e-mail
/// has ever been confirmed via OTP — i.e. whether e-mail verification is
/// actually enforced at sign-in, or just cosmetic in the UI.
Future<void> main() async {
  const supabaseUrl = 'https://clcnvcfahmvaontnnpfc.supabase.co';
  const supabaseKey = 'sb_publishable_5ZumIK_AEUzPTJtAu5oQyg_fpBaY9Rc';

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  final testEmail =
      'leulethiopia05+unconfirmed${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  const testPassword = 'TestPassword123!';

  print('Step 1: signUp (never verifying the OTP) for: $testEmail');
  try {
    final signUpRes = await client.auth.signUp(
      email: testEmail,
      password: testPassword,
    );
    print('  user id: ${signUpRes.user?.id}');
    print('  confirmed_at: ${signUpRes.user?.confirmedAt}');
    print('  session present right after signUp: ${signUpRes.session != null}');
  } on AuthException catch (e) {
    print('  signUp AuthException: ${e.statusCode} ${e.message}');
    return;
  }

  print('');
  print('Step 2: signInWithPassword using the SAME credentials, '
      'with the OTP never entered/verified.');
  try {
    final signInRes = await client.auth.signInWithPassword(
      email: testEmail,
      password: testPassword,
    );
    print('  RESULT: signInWithPassword SUCCEEDED.');
    print('  session present: ${signInRes.session != null}');
    print('  user confirmed_at: ${signInRes.user?.confirmedAt}');
    print(
      '  -> This account is fully signed in with a live session, despite '
      'never completing OTP verification.',
    );
  } on AuthException catch (e) {
    print('  RESULT: signInWithPassword correctly REJECTED.');
    print('  statusCode: ${e.statusCode}');
    print('  message: ${e.message}');
  } catch (e, st) {
    print('  RESULT: unexpected error');
    print('  $e');
    print(st);
  }
}
