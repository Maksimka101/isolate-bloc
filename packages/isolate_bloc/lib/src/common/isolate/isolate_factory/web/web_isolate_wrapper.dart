// ignore_for_file: no-empty-block
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';

/// [IIsolateWrapper] for web environment
///
/// This implementation don't maintain any isolate and used as absent Isolate wrapper
class WebIsolateWrapper extends IIsolateWrapper {
  @override
  void kill() {}
}
