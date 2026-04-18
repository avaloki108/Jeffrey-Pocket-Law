import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access your account',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithFallback({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Allow fallback to PIN/pattern
        persistAcrossBackgrounding: true,
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }
}
