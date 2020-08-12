/// Abstract layer for [Isolate]
/// For example [MockIsolateWrapper] or [IsolateWrapper] do nothing but
/// [IsolateWrapperImpl] maintain a real [Isolate]
abstract class IsolateWrapper {
  /// Kill [Isolate]
  void kill();
}
