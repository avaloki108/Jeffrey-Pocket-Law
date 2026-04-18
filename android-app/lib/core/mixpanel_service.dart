import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Service for managing Mixpanel analytics
class MixpanelService {
  static Mixpanel? _instance;

  /// Get the Mixpanel instance (lazy initialization)
  static Mixpanel get instance {
    if (_instance == null) {
      throw Exception('Mixpanel not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize Mixpanel with project token
  static Future<void> initialize() async {
    final token = dotenv.env['MIXPANEL_TOKEN'] ?? 'YOUR_MIXPANEL_TOKEN';
    _instance = await Mixpanel.init(token,
      trackAutomaticEvents: true,
      superProperties: {
        'app': 'Pocket Lawyer',
        'platform': 'mobile',
      },
    );
  }

  /// Track event with properties (supports positional or named arguments)
  static void track(String eventName, [Map<String, dynamic>? properties]) {
    instance.track(eventName, properties: properties);
  }

  /// Identify user with unique ID
  static void identifyUser(String userId) {
    instance.identify(userId);
  }

  /// Set user properties
  static void setUserProperties(Map<String, dynamic> properties) {
    final people = instance.getPeople();
    properties.forEach((key, value) {
      people.set(key, value);
    });
  }
}
