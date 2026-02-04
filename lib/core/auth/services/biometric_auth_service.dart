import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      // Fallback to old API style if AuthenticationOptions is not found
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access MotivAid',
        // options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        // If the above fails, maybe the version installed is actually older?
        // or maybe I need to cast it? No.
      );
    } on PlatformException {
      return false;
    }
  }
}