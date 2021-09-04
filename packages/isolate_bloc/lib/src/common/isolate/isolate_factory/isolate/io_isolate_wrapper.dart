import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/abstract_isolate_wrapper.dart';

/// [IsolateWrapper] for native environment 
/// Maintain a real [Isolate].
class IOIsolateWrapper extends IsolateWrapper {
  IOIsolateWrapper(this.isolate);

  final Isolate isolate;

  @override
  void kill() {
    isolate.kill();
  }
}