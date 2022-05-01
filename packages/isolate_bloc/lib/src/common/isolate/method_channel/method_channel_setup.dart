/// Signature for List of string which is used as List of method channel names.
typedef MethodChannels = List<String>;

/// Settings for MethodChannel middleware.
class MethodChannelSetup {
  const MethodChannelSetup({
    MethodChannels methodChannelNames = const [],
  }) : _methodChannelNames = methodChannelNames;

  /// List of user defined method channel names.
  ///
  /// They are used to receive platform message responses and requests.
  final MethodChannels _methodChannelNames;

  /// Returns all method channel names.
  MethodChannels get methodChannels => [..._methodChannelNames];
}
