import 'dart:async';
import 'dart:isolate';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_wrapper_impl.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_wrapper.dart';

import '../bloc_manager.dart';
import 'isolate_messenger.dart';

/// Create and initialize [Isolate] and [IsolateMessenger].
class IsolateManagerImpl extends IsolateManager {
  IsolateManagerImpl(IsolateWrapper isolate, IsolateMessenger messenger)
      : super(isolate, messenger);

  /// Create Isolate, initialize messages and run your function
  /// with [IsolateMessenger] and user's [Initializer] func
  static Future<IsolateManagerImpl> createIsolate(
      IsolateRun run, Initializer initializer) async {
    final fromIsolate = ReceivePort();
    final toIsolateCompleter = Completer<SendPort>();
    final isolate = await Isolate.spawn<_IsolateSetup>(
        _runInIsolate, _IsolateSetup(fromIsolate.sendPort, run, initializer));
    final fromIsolateStream = fromIsolate.asBroadcastStream();
    var subscription = fromIsolateStream.listen((message) {
      if (message is SendPort) {
        toIsolateCompleter.complete(message);
      }
    });
    final toIsolate = await toIsolateCompleter.future;
    await subscription.cancel();
    return IsolateManagerImpl(
      IsolateWrapperImpl(isolate),
      IsolateMessenger(fromIsolateStream, toIsolate.send),
    );
  }

  static Future<void> _runInIsolate(_IsolateSetup setup) async {
    final toIsolate = ReceivePort();
    final toIsolateStream = toIsolate.asBroadcastStream();
    setup.fromIsolate.send(toIsolate.sendPort);
    final isolateMessenger =
        IsolateMessenger(toIsolateStream, setup.fromIsolate.send);
    setup.task(isolateMessenger, setup.userInitializer);
  }
}

class _IsolateSetup {
  final SendPort fromIsolate;
  final Initializer userInitializer;
  final IsolateRun task;

  _IsolateSetup(this.fromIsolate, this.task, this.userInitializer);
}
