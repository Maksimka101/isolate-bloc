/// Library info for [PlatformChannelSetup].
class Library {
  const Library({
    required this.name,
    required this.methodChannels,
  });

  final String name;

  /// MethodChannel names that use this plugin.
  final List<String> methodChannels;
}
