import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_plugin.dart';

/// Standard flutter libraries
const flutterLibraries = <Library>[
  // tested
  Library(
    name: 'url_launcher',
    methodChannels: [
      'plugins.flutter.io/url_launcher',
    ],
  ),
  // tested
  Library(
    name: 'shared_preferences',
    methodChannels: [
      'plugins.flutter.io/shared_preferences',
    ],
  ),
  // not tested
  Library(
    name: 'android_alarm_manager_background',
    methodChannels: [
      'plugins.flutter.io/android_alarm_manager_background',
      'plugins.flutter.io/android_alarm_manager',
    ],
  ),
  // not tested
  Library(
    name: 'android_intent',
    methodChannels: [
      'plugins.flutter.io/android_intent',
    ],
  ),
  // not tested
  Library(
    name: 'battery',
    methodChannels: [
      'plugins.flutter.io/battery',
      'plugins.flutter.io/charging',
    ],
  ),
  // not tested
  Library(
    name: 'connectivity',
    methodChannels: [
      'plugins.flutter.io/connectivity',
      'plugins.flutter.io/connectivity_status',
    ],
  ),
  // not tested
  Library(
    name: 'device_info',
    methodChannels: [
      'plugins.flutter.io/device_info',
    ],
  ),
  // not tested
  Library(
    name: 'google_sign_in',
    methodChannels: [
      'plugins.flutter.io/google_sign_in',
    ],
  ),
  // not tested
  Library(
    name: 'in_app_purchase',
    methodChannels: [
      'plugins.flutter.io/in_app_purchase',
      'plugins.flutter.io/in_app_purchase_callback'
    ],
  ),
  // not tested
  Library(
    name: 'local_auth',
    methodChannels: [
      'plugins.flutter.io/local_auth',
    ],
  ),
  // not tested
  Library(
    name: 'package_info',
    methodChannels: [
      'plugins.flutter.io/package_info',
    ],
  ),
  // not tested
  Library(
    name: 'path_provider',
    methodChannels: [
      'plugins.flutter.io/path_provider',
    ],
  ),
  // not tested
  Library(
    name: 'quick_actions',
    methodChannels: [
      'plugins.flutter.io/quick_actions',
    ],
  ),
  // not tested
  Library(
    name: 'sensors',
    methodChannels: [
      'plugins.flutter.io/sensors/accelerometer',
      'plugins.flutter.io/sensors/user_accel',
      'plugins.flutter.io/sensors/gyroscope',
    ],
  ),
  // not tested
  Library(
    name: 'share',
    methodChannels: [
      'plugins.flutter.io/share',
    ],
  ),
];

/// Firebase flutter libraries
const flutterFire = <Library>[
  // not tested
  Library(
    name: 'firebase_admob',
    methodChannels: [
      'plugins.flutter.io/firebase_admob',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_analytics',
    methodChannels: [
      'plugins.flutter.io/firebase_analytics',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_auth',
    methodChannels: [
      'plugins.flutter.io/firebase_auth',
    ],
  ),
  // not tested
  Library(
    name: 'cloud_firestore',
    methodChannels: [
      'plugins.flutter.io/cloud_firestore',
    ],
  ),
  // not tested
  Library(
    name: 'cloud_functions',
    methodChannels: [
      'plugins.flutter.io/cloud_functions',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_messaging',
    methodChannels: [
      'plugins.flutter.io/firebase_messaging_background',
      'plugins.flutter.io/firebase_messaging',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_storage',
    methodChannels: [
      'plugins.flutter.io/firebase_storage',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_core',
    methodChannels: [
      'plugins.flutter.io/firebase_core',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_crashlytics',
    methodChannels: [
      'plugins.flutter.io/firebase_crashlytics',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_database',
    methodChannels: [
      'plugins.flutter.io/firebase_database',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_dynamic_links',
    methodChannels: [
      'plugins.flutter.io/firebase_dynamic_links',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_in_app_messaging',
    methodChannels: [
      'plugins.flutter.io/firebase_in_app_messaging',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_ml_vision',
    methodChannels: [
      'plugins.flutter.io/firebase_ml_vision',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_performance',
    methodChannels: [
      'plugins.flutter.io/firebase_performance',
    ],
  ),
  // not tested
  Library(
    name: 'firebase_remote_config',
    methodChannels: [
      'plugins.flutter.io/firebase_remote_config',
    ],
  ),
];

const communityLibraries = <Library>[
  // not tested
  Library(
    name: 'location',
    methodChannels: [
      'lyokone/location',
      'lyokone/locationstream',
    ],
  ),
  // not tested
  Library(
    name: 'sqflite',
    methodChannels: [
      'com.tekartik.sqflite',
    ],
  ),
  // not tested
  Library(
    name: 'geolocator',
    methodChannels: [
      'flutter.baseflow.com/geolocator/methods',
      'flutter.baseflow.com/geolocator/events',
    ],
  ),
  // not tested
  Library(
    name: 'sign_in_with_apple',
    methodChannels: [
      'com.aboutyou.dart_packages.sign_in_with_apple',
    ],
  ),
];
