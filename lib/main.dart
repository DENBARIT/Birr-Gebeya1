import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/design_system.dart';
import 'models/app_state.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file and verify required keys.
  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_KEY'];

  // Debug: print which env vars were loaded (mask sensitive values).
  debugPrint('Loaded .env keys: ' + dotenv.env.keys.join(', '));
  debugPrint('SUPABASE_URL: ${supabaseUrl ?? "<missing>"}');
  debugPrint(
    'SUPABASE_ANON_KEY present: ${dotenv.env['SUPABASE_ANON_KEY'] != null}',
  );
  debugPrint('SUPABASE_KEY present: ${dotenv.env['SUPABASE_KEY'] != null}');

  if (supabaseUrl == null || supabaseKey == null) {
    // Fail fast in development so developers can see the configuration problem.
    // In production you may want to show a friendly UI instead.
    final missing = <String>[];
    if (supabaseUrl == null) missing.add('SUPABASE_URL');
    if (supabaseKey == null) {
      missing.add('SUPABASE_ANON_KEY or SUPABASE_KEY');
    }
    final message =
        'Missing required environment variables: ${missing.join(', ')}';
    debugPrint('ERROR: $message');
    // Throwing prevents the app from running in a misconfigured state.
    throw Exception(message);
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      // disable automatic auth persistence to keep behavior explicit
      authCallbackUrlHostname: 'login-callback',
    );
    debugPrint('Supabase initialized successfully');
  } catch (e, st) {
    debugPrint('Supabase.initialize failed: $e');
    debugPrint('$st');
    rethrow;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ብር Gebeya',
      theme: BirrTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => const SplashScreen()},
    );
  }
}
