import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/io_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/web_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

import 'isolate_messenger.dart';

/// Signature for function which will run in isolate
typedef IsolateRun = void Function(
  IsolateMessenger messenger,
  Initializer initializer,
);

class IsolateCreateResult {
  IsolateCreateResult(this.isolate, this.messenger);

  final IsolateWrapper isolate;
  final IsolateMessenger messenger;
}

/// Abstract factory to create [IsolateWrapper] and [IsolateMessenger]
///
/// Implementations:
///  - [IOIsolateFactory]
///  - [WebIsolateFactory]
abstract class IsolateFactory {
  /// Function which creates [IsolateCreateResult]
  Future<IsolateCreateResult> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels);
}
