import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_wrapper.dart';

class IsolateWrapperImpl extends IsolateWrapper {
  final Isolate isolate;

  IsolateWrapperImpl(this.isolate);

  @override
  void kill() {
    isolate.kill();
  }
}
