// ignore_for_file: no-empty-bloc
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';

/// [IIsolateWrapper] for web environment
class WebIsolateWrapper extends IIsolateWrapper {
  @override
  // ignore: no-empty-block
  void kill() {}
}
