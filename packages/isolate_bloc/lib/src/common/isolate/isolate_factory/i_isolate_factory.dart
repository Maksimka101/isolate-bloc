import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

import 'isolate_messenger.dart';

/// Abstract factory to create [IIsolateWrapper] and [IsolateMessenger]
///
/// Implementations:
///  - [IOIsolateFactory]
///  - [WebIsolateFactory]
abstract class IIsolateFactory {
  /// Function which creates [IsolateCreateResult]
  Future<IsolateCreateResult> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels);
}

/// Signature for function which will run in isolate
typedef IsolateRun = void Function(
  IsolateMessenger messenger,
  Initializer initializer,
);

class IsolateCreateResult {
  IsolateCreateResult(this.isolate, this.messenger);

  final IIsolateWrapper isolate;
  final IsolateMessenger messenger;
}
