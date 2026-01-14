import 'package:flutter/foundation.dart';

class ApiConfig {
  // Override at build/run time:
  // flutter run --dart-define=API_BASE_URL=http://<IP>:3000/api
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.trim().isNotEmpty) {
      return _overrideBaseUrl.trim();
    }

    // Sensible defaults:
    // - Web runs on the same machine as the backend most of the time.
    // - Android emulator reaches host machine via 10.0.2.2.
    // - Physical devices must use --dart-define (or adb reverse).
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }
}
