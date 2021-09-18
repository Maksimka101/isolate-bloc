/// Library info for [PlatformChannelSetup].
class Library {
  const Library({
    required this.name,
    required this.methodChannels,
  });

  /// Library name.
  ///
  /// It is necessary only for conveniences when reading.
  final String name;

  /// MethodChannel names that use this plugin.
  final List<String> methodChannels;
}
