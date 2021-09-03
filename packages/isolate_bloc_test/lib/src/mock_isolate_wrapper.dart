import 'package:isolate_bloc/isolate_bloc.dart';

/// [IsolateWrapper] for mock [IsolateCreateResult]
class MockIsolateWrapper extends IsolateWrapper {
  @override
  void kill() {}
}
