import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';

/// [IIsolateWrapper] for native environment 
/// Maintain a real [Isolate].
class IOIsolateWrapper extends IIsolateWrapper {
  IOIsolateWrapper(this.isolate);

  final Isolate isolate;

  @override
  void kill() {
    isolate.kill();
  }
}
