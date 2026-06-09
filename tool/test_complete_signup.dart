// import 'package:supabase/supabase.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';
// import 'dart:io';

// void main() async {
//   // 1. Load .env file
//   try {
//     await dotenv.load(fileName: '.env');
//     print('SUCCESS: Loaded .env variables');
//   } catch (e) {
//     print('ERROR: Failed to load .env: $e');
//     return;
//   }

//   final emailUser = dotenv.env['EMAIL_USER'] ?? '';
//   final emailPass = dotenv.env['EMAIL_PASS'] ?? '';
//   final emailHost = dotenv.env['EMAIL_HOST'] ?? '';
//   final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://clcnvcfahmvaontnnpfc.supabase.co';
//   final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_5ZumIK_AEUzPTJtAu5oQyg_fpBaY9Rc';

//   final targetEmail = 'leulethiopia05@gmail.com';
//   final targetPassword = 'wcvnM13#';

//   print('=== STEP 1: Attempting to send Email OTP via SMTP ===');
//   print('Config: host=$emailHost user=$emailUser');

//   if (emailUser.isEmpty || emailPass.isEmpty) {
//     print('ERROR: SMTP credentials (EMAIL_USER/EMAIL_PASS) are missing in .env');
//   } else {
//     final smtpServer = gmail(emailUser, emailPass);
//     final message = Message()
//       ..from = Address(emailUser, 'ብር Gebeya')
//       ..recipients.add(targetEmail)
//       ..subject = 'Your Birr Gebeya verification code'
//       ..text = 'Hello, this is a test verification email from Birr Gebeya. Your OTP code is: 928374';

//     try {
//       final sendReport = await send(message, smtpServer);
//       print('SUCCESS: SMTP email sent to $targetEmail. Report: $sendReport');
//     } catch (e, st) {
//       print('ERROR: SMTP dispatch failed: $e');
//       print(st);
//     }
//   }

//   print('\n=== STEP 2: Attempting Supabase Auth SignUp ===');
//   print('URL: $supabaseUrl');
//   print('Key: ${supabaseKey.substring(0, 15)}...');

//   final client = SupabaseClient(supabaseUrl, supabaseKey);

//   try {
//     print('Calling auth.signUp for $targetEmail...');
//     final response = await client.auth.signUp(
//       email: targetEmail,
//       password: targetPassword,
//     );

//     print('SUCCESS: Supabase signUp response:');
//     print('  User ID: ${response.user?.id}');
//     print('  Email: ${response.user?.email}');
//     print('  Confirmed At: ${response.user?.confirmedAt}');
//     print('  Identities: ${response.user?.identities?.length}');
//   } catch (e, st) {
//     print('ERROR: Supabase signUp failed: $e');
//     print(st);
//   }
// }
