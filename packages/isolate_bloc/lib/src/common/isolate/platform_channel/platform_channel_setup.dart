import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_plugin.dart';
import 'package:uuid/uuid.dart';

import 'libraries.dart';

/// Settings for [PlatformChannelMiddleware] and [IsolatedPlatformChannelMiddleware]
/// In [_platformChannelPlugins] stored all known MethodChannel plugin names.
/// They are used to receive platform message responses and requests.
/// You can add platform [MethodChannel] names with [PlatformChannelSetup.addChannels] function.
class PlatformChannelSetup {
  /// Create instance of this class.
  PlatformChannelSetup({
    String Function()? generateId,
    List<String> methodChannelNames = const [],
  }) : generateId = generateId ?? _generateId {
    _addChannels(methodChannelNames: methodChannelNames);
  }

  final String Function() generateId;

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

  /// Add [MethodChannel] names.
  void _addChannels({required List<String> methodChannelNames}) {
    _platformChannelPlugins.add(Library(
      name: generateId(),
      methodChannels: methodChannelNames,
    ));
  }

  /// Return all method channel names.
  List<String> get methodChannels {
    return _platformChannelPlugins.fold<List<String>>(
      <String>[],
      (previousValue, element) => previousValue..addAll(element.methodChannels),
    );
  }
}

final _generateId = const Uuid().v4;
