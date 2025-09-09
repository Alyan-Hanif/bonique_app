import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/view/splash_page.dart';
import 'features/onboarding/view/onboarding_page.dart';
import 'features/auth/view/auth_page.dart';
import 'features/home/view/home_page.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
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
    print('❌ Supabase initialization failed: $e');
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
      title: 'AI Stylist App',
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
