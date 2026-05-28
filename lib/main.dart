import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/design_system.dart';
import 'models/app_state.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];

  if (supabaseUrl != null && supabaseKey != null) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      // disable automatic auth persistence to keep behavior explicit
      authCallbackUrlHostname: 'login-callback',
    );
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
