import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';

/// [IsolateWrapper] for [IsolateManagerImpl]
/// Maintain a real [Isolate].
class IsolateWrapperImpl extends IsolateWrapper {
  IsolateWrapperImpl(this.isolate);

  final Isolate isolate;

  @override
  void kill() {
    isolate.kill();
  }
}
