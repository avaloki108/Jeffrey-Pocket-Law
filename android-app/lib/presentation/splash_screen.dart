import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/biometric_service.dart';
import 'providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  /// Navigates to onboarding, home, or auth after a delay.
  Future<void> _navigateNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final onboardingComplete = await storage.get('onboarding_complete');
    final savedState = await storage.get('selected_state');
    final savedJurisdiction = await storage.get('selected_jurisdiction');
    final savedCounty = await storage.get('selected_county');
    final savedPlan = await storage.get('selected_plan');

    if (savedState != null && savedState.isNotEmpty) {
      ref.read(selectedStateProvider.notifier).state = savedState;
    }
    if (savedJurisdiction != null && savedJurisdiction.isNotEmpty) {
      ref.read(selectedJurisdictionProvider.notifier).state = savedJurisdiction;
    }
    if (savedCounty != null) {
      ref.read(selectedCountyProvider.notifier).state = savedCounty;
    }
    if (savedPlan != null && savedPlan.isNotEmpty) {
      ref.read(selectedPlanProvider.notifier).state = savedPlan;
    }

    // Load personalization
    final savedUserName = await storage.get('user_name');
    final savedLawyerName = await storage.get('lawyer_name');
    final savedAgeRange = await storage.get('user_age_range');
    final savedUseCases = await storage.get('user_use_cases');
    final personalized = await storage.get('personalized');

    if (savedUserName != null && savedUserName.isNotEmpty) {
      ref.read(userNameProvider.notifier).state = savedUserName;
    }
    if (savedLawyerName != null && savedLawyerName.isNotEmpty) {
      ref.read(lawyerNameProvider.notifier).state = savedLawyerName;
    }
    if (savedAgeRange != null && savedAgeRange.isNotEmpty) {
      ref.read(userAgeRangeProvider.notifier).state = savedAgeRange;
    }
    if (savedUseCases != null && savedUseCases.isNotEmpty) {
      ref.read(userUseCasesProvider.notifier).state = savedUseCases.split(',');
    }

    if (onboardingComplete != 'true') {
      final metJeffrey = await storage.get('met_jeffrey');
      if (metJeffrey != 'true') {
        Navigator.of(context).pushReplacementNamed('/meetJeffrey');
        return;
      }
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }

    if (kDebugMode) {
      if (personalized != 'true') {
        Navigator.of(context).pushReplacementNamed('/personalize');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return;
    }

    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      },
      loading: () => Navigator.of(context).pushReplacementNamed('/auth'),
      error: (_, __) => Navigator.of(context).pushReplacementNamed('/auth'),
    );
  }

  Future<void> _checkBiometricAuth() async {
    final disableBiometric = (dotenv.maybeGet('DISABLE_BIOMETRIC') ??
                const String.fromEnvironment('DISABLE_BIOMETRIC',
                    defaultValue: 'false'))
            .toLowerCase() ==
        'true';
    if (disableBiometric) {
      await _navigateNext();
      return;
    }

    final isAvailable = await _biometricService.isBiometricAvailable();

    if (isAvailable) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access Pocket Lawyer',
      );

      if (authenticated) {
        await _navigateNext();
      } else {
        _showAuthFailedDialog();
      }
    } else {
      await _navigateNext();
    }
  }

  void _showAuthFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text('Unable to authenticate. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkBiometricAuth();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
