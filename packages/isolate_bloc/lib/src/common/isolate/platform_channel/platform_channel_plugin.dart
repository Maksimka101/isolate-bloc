import 'package:flutter/foundation.dart';

class Plugin {
  final String name;
  final List<String> methodChannels;

  Plugin({
    @required this.name,
    @required this.methodChannels,
  });
}
