import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Abstract factory to create [IIsolateWrapper] and [IIsolateMessenger]
///
/// Implementations:
///  - [IOIsolateFactory]
///  - [WebIsolateFactory]
abstract class IIsolateFactory {
  /// Function which creates [IsolateCreateResult]
  Future<IsolateCreateResult> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels);
}

/// Signature for function which will run in isolate
typedef IsolateRun = FutureOr<void> Function(
  IIsolateMessenger messenger,
  Initializer initializer,
);

class IsolateCreateResult {
  IsolateCreateResult(this.isolate, this.messenger);

  final IIsolateWrapper isolate;
  final IIsolateMessenger messenger;
}
