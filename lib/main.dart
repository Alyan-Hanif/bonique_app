import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'features/splash/view/splash_page.dart';
import 'features/onboarding/view/onboarding_page.dart';
import 'features/demo/view/demo_intro_page.dart';
import 'features/demo/view/demo_video_page.dart';
import 'features/auth/view/auth_page.dart';
import 'features/auth/view/update_password_page.dart';
import 'features/home/view/home_page.dart';
import 'core/services/supabase_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/session_manager.dart';
import 'core/services/version_checker.dart';
import 'core/utils/connectivity_utils.dart';
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

    // Initialize session manager for token handling
    SessionManager().initialize();
    print('✅ Session manager initialized');

    // Check app version and logout if needed (on install/update)
    final versionChanged = await VersionChecker.checkVersionAndLogout();
    if (versionChanged) {
      print('🔄 App version changed - user logged out for security');
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService();
  final SessionManager _sessionManager = SessionManager();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Initialize deep link service with navigator key
    _deepLinkService.initialize(navigatorKey);

    // Add lifecycle observer to handle app state changes
    WidgetsBinding.instance.addObserver(this);

    // Listen to connectivity changes
    _connectivitySubscription = ConnectivityUtils.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    _sessionManager.dispose();
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (hasConnection) {
      print('🌐 Network connection restored');
      _sessionManager.onConnectivityChange(true);
    } else {
      print('📵 Network connection lost');
      _sessionManager.onConnectivityChange(false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - check session health
        print('📱 App resumed - checking session...');
        _sessionManager.onAppResume();
        break;
      case AppLifecycleState.paused:
        print('📱 App paused');
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: EnvConfig.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA45A41),
          primary: const Color(0xFFA45A41),
          secondary: const Color(0xFFE9E2C6),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        SplashPage.route: (context) => const SplashPage(),
        OnboardingPage.route: (context) => const OnboardingPage(),
        DemoIntroPage.route: (context) => const DemoIntroPage(),
        DemoVideoPage.route: (context) => const DemoVideoPage(),
        AuthPage.route: (context) => const AuthPage(),
        UpdatePasswordPage.route: (context) => const UpdatePasswordPage(),
        HomePage.route: (context) => const HomePage(),

        // Add more routes as needed
      },
    );
  }
}
