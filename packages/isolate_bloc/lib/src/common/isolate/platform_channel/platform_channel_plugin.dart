import 'package:flutter/foundation.dart';

/// Library info for [PlatformChannelSetup].
class Plugin {
  Plugin({
    @required this.name,
    @required this.methodChannels,
  });

  final String name;

  /// MethodChannel names that use this plugin.
  final List<String> methodChannels;
}
