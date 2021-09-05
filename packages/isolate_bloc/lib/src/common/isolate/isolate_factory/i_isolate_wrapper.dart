/// Abstract layer for [Isolate]
/// For example [MockIsolateWrapper] or [IIsolateWrapper] do nothing but
/// [IsolateWrapperImpl] maintain a real [Isolate]
abstract class IIsolateWrapper {
  /// Kill [Isolate]
  void kill();
}
