import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

import 'isolate_messenger.dart';

/// Signature for function which will run in isolate
typedef IsolateRun = void Function(
  IsolateMessenger messenger,
  Initializer initializer,
);

/// Abstract class for [IsolateManagerImpl] which implement work with real [Isolate],
/// [MockIsolateManager] which doesn't create a real [Isolate] and web implementation
class IsolateManager {
  IsolateManager(this.isolate, this.messenger);

  final IsolateWrapper isolate;
  final IsolateMessenger messenger;
}

/// Abstract factory to create [IsolateManager] instance
///
/// Implementations:
///  - [IOIsolateManagerFactory]
///  - [WebIsolateManagerFactory]
abstract class IsolateManagerFactory {
  /// Function which creates [IsolateManager]
  Future<IsolateManager> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels);
}
