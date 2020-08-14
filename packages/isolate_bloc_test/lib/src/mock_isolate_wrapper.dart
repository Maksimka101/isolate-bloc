import 'package:isolate_bloc/isolate_bloc.dart';

/// [IsolateWrapper] for [MockIsolateManager]
class MockIsolateWrapper extends IsolateWrapper {
  @override
  void kill() {}
}
