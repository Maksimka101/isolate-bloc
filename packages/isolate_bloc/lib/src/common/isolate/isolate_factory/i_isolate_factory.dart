import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_setup.dart';

/// Abstract factory which is used to create and initialize [IIsolateWrapper], [IIsolateMessenger]
/// and optionally [UIMethodChannelMiddleware] and [IsolatedMethodChannelMiddleware].
///
/// Implementations:
///  - [IOIsolateFactory]
///  - [WebIsolateFactory]
abstract class IIsolateFactory {
  /// Function which creates and initializes [IIsolateWrapper], [IIsolateMessenger]
  /// and optionally [UIMethodChannelMiddleware] and [IsolatedMethodChannelMiddleware]
  Future<IsolateCreateResult> create(
    IsolateRun isolateRun,
    Initializer initializer,
    MethodChannels methodChannels,
  );
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
