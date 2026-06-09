// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:io';

// void main() async {
//   try {
//     await dotenv.load(fileName: '.env');
//   } catch (e) {
//     print('No .env file found');
//   }

//   // Use the new publishable key
//   final url = 'https://clcnvcfahmvaontnnpfc.supabase.co';
//   final anonKey = 'sb_publishable_5ZumIK_AEUzPTJtAu5oQyg_fpBaY9Rc';

//   print('Initializing Supabase with url=$url...');
//   await Supabase.initialize(
//     url: url,
//     anonKey: anonKey,
//   );

//   final client = Supabase.instance.client;
//   final email = 'test_signup_${DateTime.now().millisecondsSinceEpoch}@example.com';
//   final password = 'TestPassword123!';

//   print('Attempting signUp with email=$email...');
//   try {
//     final response = await client.auth.signUp(
//       email: email,
//       password: password,
//     );
//     print('Sign up response:');
//     print('User: ${response.user?.id}');
//     print('Confirmed: ${response.user?.confirmedAt}');
//     print('Identities: ${response.user?.identities?.length}');

//     if (response.user != null) {
//       print('SUCCESS: Supabase signUp called successfully!');
//     }
//   } catch (e, st) {
//     print('SignUp failed: $e');
//     print(st);
//   }
// }
