/// Abstract layer for [Isolate]
///
/// For example [WebIsolateWrapper] do nothing
/// however [IOIsolateWrapper] maintains a real [Isolate]
abstract class IIsolateWrapper {
  /// Kills [Isolate]
  void kill();
}
