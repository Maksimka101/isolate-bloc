import 'package:isolate_bloc/src/common/isolate/method_channel/library.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';

import 'libraries.dart';

/// Signature for List of string which is used as List of method channel names.
typedef MethodChannels = List<String>;

/// Settings for [UIMethodChannelMiddleware] and [IsolatedMethodChannelMiddleware].
class MethodChannelSetup {
  const MethodChannelSetup({
    final MethodChannels methodChannelNames = const [],
  }) : _methodChannelNames = methodChannelNames;

  /// List of user defined method channel names.
  ///
  /// They are used to receive platform message responses and requests.
  final MethodChannels _methodChannelNames;

  /// List with platformChannel packages. Package contains library name and it's [MethodChannel] names.
  ///
  /// Method channel name is a name which is used by MethodChannel.
  /// For example:
  /// ```dart
  /// final batteryMethodChannel = MethodChannel('samples.flutter.dev/battery');
  /// ```
  /// In example above method channel name is `samples.flutter.dev/battery`.
  /// Read more about platform channels here https://flutter.dev/docs/development/platform-integration/platform-channels
  static final _methodChannelPlugins = <Library>[
    ...flutterLibraries,
    ...flutterFire,
    ...communityLibraries,
  ];

  /// Returns all method channel names.
  MethodChannels get methodChannels {
    return [
      for (final plugin in _methodChannelPlugins) ...plugin.methodChannels,
      ..._methodChannelNames,
    ];
  }
}
