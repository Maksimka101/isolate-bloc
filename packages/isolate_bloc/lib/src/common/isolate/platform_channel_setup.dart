import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class PlatformChannelSetup {
  final String Function() generateId;

  /// Map with platformChannel package names and their [MethodChannel] names.
  ///
  /// Method channel name is a name which is used by MethodChannel. For example:
  /// ```dart
  /// final batteryMethodChannel = MethodChannel('samples.flutter.dev/battery');
  /// ```
  /// In example above method channel name is `samples.flutter.dev/battery`.
  /// Read more about platform channels here https://flutter.dev/docs/development/platform-integration/platform-channels
  static final _platformChannels = <String, String>{
    'url_launcher': 'plugins.flutter.io/url_launcher',
  };

  const PlatformChannelSetup({
    String Function() generateId,
  }) : generateId = generateId ?? _generateId;

  /// Remove [MethodChannel] names by [packageNames]
  void removeChannels({@required List<String> packageNames}) =>
      _platformChannels.removeWhere((key, value) => packageNames.contains(key));

  /// Add [MethodChannel] names.
  void addChannels({@required List<String> methodChannelNames}) {
    for (final channel in methodChannelNames) {
      _platformChannels[generateId()] = channel;
    }
  }

  List<String> get platformChannels => _platformChannels.values.toList();
}

String _generateId() => Random().nextDouble().toString();
