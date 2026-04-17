import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/constants.dart';
import 'core/themes.dart';
import 'firebase_options.dart';
import 'presentation/auth_screen.dart';
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
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  // Also capture any asynchronous errors
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Google Mobile Ads only on mobile platforms
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    MobileAds.instance.initialize();
  }

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
  final NavigatorObserver? navigatorObserver;
  const MyApp({super.key, this.navigatorObserver});

  @override
  Widget build(BuildContext context) {
    final observers = <NavigatorObserver>[];
    if (navigatorObserver != null) {
      observers.add(navigatorObserver!);
    } else {
      observers.add(FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      ));
    }

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      initialRoute: '/',
      navigatorObservers: observers,
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          return MaterialPageRoute(
            builder: (context) => const ChatScreen(),
            settings: settings,
          );
        }
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          case '/auth':
            return MaterialPageRoute(builder: (context) => const AuthScreen());
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
