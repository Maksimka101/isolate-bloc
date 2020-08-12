import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';

/// [IsolateWrapper] for  [MockIsolateManager]
class MockIsolateWrapper extends IsolateWrapper {
  @override
  void kill() {}
}
