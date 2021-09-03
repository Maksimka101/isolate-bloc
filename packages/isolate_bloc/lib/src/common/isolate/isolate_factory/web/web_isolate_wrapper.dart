
import 'package:isolate_bloc/src/common/isolate/isolate_factory/abstract_isolate_wrapper.dart';

/// [IsolateWrapper] for web environment
class WebIsolateWrapper extends IsolateWrapper {
  @override
  void kill() {}
}
