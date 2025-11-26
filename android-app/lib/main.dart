import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/constants.dart';
import 'core/themes.dart';
import 'firebase_options.dart';
import 'presentation/chat_screen.dart';
import 'presentation/home_screen.dart';
import 'presentation/prompts_screen.dart';
import 'presentation/settings_screen.dart';
import 'presentation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics error handling for Flutter and platform errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Forward to Crashlytics as fatal Flutter error
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  // Also capture any asynchronous errors
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Google Mobile Ads in background (non-blocking)
  MobileAds.instance.initialize();

  // Attempt to load .env file (optional). If missing, proceed; keys may come from --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env.example');
    } catch (_) {}
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a Firebase Analytics observer to automatically log navigation events
    final analyticsObserver = FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      initialRoute: '/',
      navigatorObservers: [analyticsObserver],
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/chat') {
          return MaterialPageRoute(
            builder: (context) => const ChatScreen(),
            settings: settings,
          );
        }
        // Default routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/prompts':
            return MaterialPageRoute(
                builder: (context) => const PromptsScreen());
          case '/settings':
            return MaterialPageRoute(
                builder: (context) => const SettingsScreen());
          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
