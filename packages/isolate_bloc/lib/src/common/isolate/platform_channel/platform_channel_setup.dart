import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_plugin.dart';

import 'libraries.dart';

/// Signature for List of string which is used as List of method channel names
typedef MethodChannels = List<String>;

/// Settings for [PlatformChannelMiddleware] and [IsolatedPlatformChannelMiddleware]
/// In [_platformChannelPlugins] stored all known MethodChannel plugin names.
/// They are used to receive platform message responses and requests.
class PlatformChannelSetup {
  /// Create instance of this class.
  const PlatformChannelSetup({
    final List<String> methodChannelNames = const [],
  }) : _methodChannelNames = methodChannelNames;

  /// List of user defined method channel names
  final List<String> _methodChannelNames;

  /// List with platformChannel packages. Package contains library name and their [MethodChannel]'s names.
  ///
  /// Method channel name is a name which is used by MethodChannel. For example:
  /// ```dart
  /// final batteryMethodChannel = MethodChannel('samples.flutter.dev/battery');
  /// ```
  /// In example above method channel name is `samples.flutter.dev/battery`.
  /// Read more about platform channels here https://flutter.dev/docs/development/platform-integration/platform-channels
  static final _platformChannelPlugins = <Library>[
    ...flutterLibraries,
    ...flutterFire,
    ...communityLibraries,
  ];

  /// Return all method channel names.
  MethodChannels get methodChannels {
    return [
      for (final plugin in _platformChannelPlugins) ...plugin.methodChannels,
      ..._methodChannelNames,
    ];
  }
}
