
import 'package:isolate_bloc/src/common/isolate/method_channel/library.dart';

/// Standard flutter libraries
const flutterLibraries = <Library>[
  Library(
    name: 'flutter_assets',
    methodChannels: [
      'flutter/assets',
    ],
  ),
  Library(
    name: 'url_launcher',
    methodChannels: [
      'plugins.flutter.io/url_launcher',
    ],
  ),
  Library(
    name: 'shared_preferences',
    methodChannels: [
      'plugins.flutter.io/shared_preferences',
    ],
  ),
  Library(
    name: 'android_alarm_manager_background',
    methodChannels: [
      'plugins.flutter.io/android_alarm_manager_background',
      'plugins.flutter.io/android_alarm_manager',
    ],
  ),
  Library(
    name: 'android_intent',
    methodChannels: [
      'plugins.flutter.io/android_intent',
    ],
  ),
  Library(
    name: 'battery',
    methodChannels: [
      'plugins.flutter.io/battery',
      'plugins.flutter.io/charging',
    ],
  ),
  Library(
    name: 'connectivity',
    methodChannels: [
      'plugins.flutter.io/connectivity',
      'plugins.flutter.io/connectivity_status',
    ],
  ),
  Library(
    name: 'device_info',
    methodChannels: [
      'plugins.flutter.io/device_info',
    ],
  ),
  Library(
    name: 'google_sign_in',
    methodChannels: [
      'plugins.flutter.io/google_sign_in',
    ],
  ),
  Library(
    name: 'in_app_purchase',
    methodChannels: [
      'plugins.flutter.io/in_app_purchase',
      'plugins.flutter.io/in_app_purchase_callback'
    ],
  ),
  Library(
    name: 'local_auth',
    methodChannels: [
      'plugins.flutter.io/local_auth',
    ],
  ),
  Library(
    name: 'package_info',
    methodChannels: [
      'plugins.flutter.io/package_info',
    ],
  ),
  Library(
    name: 'path_provider',
    methodChannels: [
      'plugins.flutter.io/path_provider',
    ],
  ),
  Library(
    name: 'quick_actions',
    methodChannels: [
      'plugins.flutter.io/quick_actions',
    ],
  ),
  Library(
    name: 'sensors',
    methodChannels: [
      'plugins.flutter.io/sensors/accelerometer',
      'plugins.flutter.io/sensors/user_accel',
      'plugins.flutter.io/sensors/gyroscope',
    ],
  ),
  Library(
    name: 'share',
    methodChannels: [
      'plugins.flutter.io/share',
    ],
  ),
];

/// Firebase flutter libraries
const flutterFire = <Library>[
  Library(
    name: 'firebase_admob',
    methodChannels: [
      'plugins.flutter.io/firebase_admob',
    ],
  ),
  Library(
    name: 'firebase_analytics',
    methodChannels: [
      'plugins.flutter.io/firebase_analytics',
    ],
  ),
  Library(
    name: 'firebase_auth',
    methodChannels: [
      'plugins.flutter.io/firebase_auth',
    ],
  ),
  Library(
    name: 'cloud_firestore',
    methodChannels: [
      'plugins.flutter.io/cloud_firestore',
    ],
  ),
  Library(
    name: 'cloud_firestore_new_version',
    methodChannels: [
      'plugins.flutter.io/firebase_firestore',
    ],
  ),
  Library(
    name: 'cloud_functions',
    methodChannels: [
      'plugins.flutter.io/cloud_functions',
    ],
  ),
  Library(
    name: 'firebase_messaging',
    methodChannels: [
      'plugins.flutter.io/firebase_messaging_background',
      'plugins.flutter.io/firebase_messaging',
    ],
  ),
  Library(
    name: 'firebase_storage',
    methodChannels: [
      'plugins.flutter.io/firebase_storage',
    ],
  ),
  Library(
    name: 'firebase_core',
    methodChannels: [
      'plugins.flutter.io/firebase_core',
    ],
  ),
  Library(
    name: 'firebase_crashlytics',
    methodChannels: [
      'plugins.flutter.io/firebase_crashlytics',
    ],
  ),
  Library(
    name: 'firebase_database',
    methodChannels: [
      'plugins.flutter.io/firebase_database',
    ],
  ),
  Library(
    name: 'firebase_dynamic_links',
    methodChannels: [
      'plugins.flutter.io/firebase_dynamic_links',
    ],
  ),
  Library(
    name: 'firebase_in_app_messaging',
    methodChannels: [
      'plugins.flutter.io/firebase_in_app_messaging',
    ],
  ),
  Library(
    name: 'firebase_ml_vision',
    methodChannels: [
      'plugins.flutter.io/firebase_ml_vision',
    ],
  ),
  Library(
    name: 'firebase_performance',
    methodChannels: [
      'plugins.flutter.io/firebase_performance',
    ],
  ),
  Library(
    name: 'firebase_remote_config',
    methodChannels: [
      'plugins.flutter.io/firebase_remote_config',
    ],
  ),
];

const communityLibraries = <Library>[
  Library(
    name: 'location',
    methodChannels: [
      'lyokone/location',
      'lyokone/locationstream',
    ],
  ),
  Library(
    name: 'sqflite',
    methodChannels: [
      'com.tekartik.sqflite',
    ],
  ),
  Library(
    name: 'geolocator',
    methodChannels: [
      'flutter.baseflow.com/geolocator/methods',
      'flutter.baseflow.com/geolocator/events',
    ],
  ),
  Library(
    name: 'sign_in_with_apple',
    methodChannels: [
      'com.aboutyou.dart_packages.sign_in_with_apple',
    ],
  ),
];
