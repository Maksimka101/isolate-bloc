import 'package:flutter/cupertino.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_plugin.dart';
import 'package:uuid/uuid.dart';

/// Settings for [PlatformChannelMiddleware] and [IsolatedPlatformChannelMiddleware]
/// In [_platformChannelPlugins] stored all known MethodChannel plugin names.
/// They are used to receive platform message responses and requests. 
/// You can add platform [MethodChannel] names with [PlatformChannelSetup.addChannels]
/// function and remove them by package name with [PlatformChannelSetup.removeChannels] function.
class PlatformChannelSetup {

  /// Create instance of this class.
  const PlatformChannelSetup({
    String Function() generateId,
  }) : generateId = generateId ?? _generateId;

  final String Function() generateId;

  /// Map with platformChannel package names and their [MethodChannel] names.
  ///
  /// Method channel name is a name which is used by MethodChannel. For example:
  /// ```dart
  /// final batteryMethodChannel = MethodChannel('samples.flutter.dev/battery');
  /// ```
  /// In example above method channel name is `samples.flutter.dev/battery`.
  /// Read more about platform channels here https://flutter.dev/docs/development/platform-integration/platform-channels
  static final _platformChannelPlugins = <Plugin>[
    // tested
    Plugin(
      name: 'url_launcher',
      methodChannels: [
        'plugins.flutter.io/url_launcher',
      ],
    ),
    // tested
    Plugin(
      name: 'shared_preferences',
      methodChannels: [
        'plugins.flutter.io/shared_preferences',
      ],
    ),
    // not tested
    Plugin(
      name: 'android_alarm_manager_background',
      methodChannels: [
        'plugins.flutter.io/android_alarm_manager_background',
        'plugins.flutter.io/android_alarm_manager',
      ],
    ),
    // not tested
    Plugin(
      name: 'android_intent',
      methodChannels: [
        'plugins.flutter.io/android_intent',
      ],
    ),
    // not tested
    Plugin(
      name: 'battery',
      methodChannels: [
        'plugins.flutter.io/battery',
        'plugins.flutter.io/charging',
      ],
    ),
    // not tested
    Plugin(
      name: 'connectivity',
      methodChannels: [
        'plugins.flutter.io/connectivity',
        'plugins.flutter.io/connectivity_status',
      ],
    ),
    // not tested
    Plugin(
      name: 'device_info',
      methodChannels: [
        'plugins.flutter.io/device_info',
      ],
    ),
    // not tested
    Plugin(
      name: 'google_sign_in',
      methodChannels: [
        'plugins.flutter.io/google_sign_in',
      ],
    ),
    // not tested
    Plugin(
      name: 'in_app_purchase',
      methodChannels: [
        'plugins.flutter.io/in_app_purchase',
        'plugins.flutter.io/in_app_purchase_callback'
      ],
    ),
    // not tested
    Plugin(
      name: 'local_auth',
      methodChannels: [
        'plugins.flutter.io/local_auth',
      ],
    ),
    // not tested
    Plugin(
      name: 'package_info',
      methodChannels: [
        'plugins.flutter.io/package_info',
      ],
    ),
    // not tested
    Plugin(
      name: 'path_provider',
      methodChannels: [
        'plugins.flutter.io/path_provider',
      ],
    ),
    // not tested
    Plugin(
      name: 'quick_actions',
      methodChannels: [
        'plugins.flutter.io/quick_actions',
      ],
    ),
    // not tested
    Plugin(
      name: 'sensors',
      methodChannels: [
        'plugins.flutter.io/sensors/accelerometer',
        'plugins.flutter.io/sensors/user_accel',
        'plugins.flutter.io/sensors/gyroscope',
      ],
    ),
    // not tested
    Plugin(
      name: 'share',
      methodChannels: [
        'plugins.flutter.io/share',
      ],
    ),
  ];

  /// Remove [MethodChannel] names from [_platformChannelPlugins] by [packageNames]
  void removeChannels({@required List<String> packageNames}) =>
      _platformChannelPlugins
          .removeWhere((plugin) => packageNames.contains(plugin.name));

  /// Add [MethodChannel] names.
  void addChannels({@required List<String> methodChannelNames}) {
    _platformChannelPlugins
        .add(Plugin(name: generateId(), methodChannels: methodChannelNames));
  }

  /// Return all method channel names. 
  List<String> get methodChannels {
    return _platformChannelPlugins.fold<List<String>>(
      <String>[],
      (previousValue, element) => previousValue..addAll(element.methodChannels),
    );
  }
}

String _generateId() => Uuid().v4();
