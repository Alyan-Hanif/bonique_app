import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/view/splash_page.dart';
import 'features/onboarding/view/onboarding_page.dart';
import 'features/auth/view/auth_page.dart';
import 'features/home/view/home_page.dart';
import 'core/services/supabase_service.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment configuration first
    await EnvConfig.init();
    print('✅ Environment configuration loaded');

    // Validate environment variables
    if (!EnvConfig.validateConfig()) {
      throw Exception('Missing required environment variables');
    }
    print('✅ Environment variables validated');

    // Initialize Supabase with environment variables
    await SupabaseService.init();
    print('✅ Supabase initialized successfully');

    // Test the connection
    final isConnected = await SupabaseService.testConnection();
    if (isConnected) {
      print('✅ Supabase connection test passed');
    } else {
      print('⚠️ Supabase connection test failed');
    }
  } catch (e) {
    print('❌ Initialization failed: $e');
    // You might want to show an error screen or handle this gracefully
  }

  runApp(
    const ProviderScope(
      // Wrap whole app
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(primary: const Color(0xFFFF6B2C)),
        useMaterial3: false,
      ),
      home: const SplashPage(),
      routes: {
        SplashPage.route: (context) => const SplashPage(),
        OnboardingPage.route: (context) => const OnboardingPage(),
        AuthPage.route: (context) => const AuthPage(),
        HomePage.route: (context) => const HomePage(),
      },
    );
  }
}
