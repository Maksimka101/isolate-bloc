// ignore_for_file: no-empty-block
import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';

/// [IIsolateWrapper] for web environment.
///
/// This implementation don't maintain any isolate and only stores mock isolate streams.
class WebIsolateWrapper extends IIsolateWrapper {
  WebIsolateWrapper({required this.fromIsolate, required this.toIsolate});

  final StreamController fromIsolate;
  final StreamController toIsolate;

  @override
  void kill() {
    fromIsolate.close();
    toIsolate.close();
  }
}
