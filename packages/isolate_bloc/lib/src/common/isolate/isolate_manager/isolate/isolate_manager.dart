import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_binding.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/isolated_platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_middleware.dart';
import 'package:uuid/uuid.dart';

import '../../bloc_manager.dart';
import '../isolate_messenger.dart';
import 'isolate_wrapper_impl.dart';

/// Create and initialize [Isolate] and [IsolateMessenger].
class IsolateManagerImpl extends IsolateManager {
  IsolateManagerImpl(IsolateWrapper isolate, IsolateMessenger messenger)
      : super(isolate, messenger);

  /// Create Isolate, initialize messages and run your function
  /// with [IsolateMessenger] and user's [Initializer] func
  static Future<IsolateManagerImpl> createIsolate(
      IsolateRun run, Initializer initializer,
      [List<String> platformChannels]) async {
    assert(
      '$initializer'.contains(' static'),
      '$Initializer must be a static or global function',
    );

    final fromIsolate = ReceivePort();
    final toIsolateCompleter = Completer<SendPort>();
    final isolate = await Isolate.spawn<_IsolateSetup>(
      _runInIsolate,
      _IsolateSetup(
        fromIsolate.sendPort,
        run,
        initializer,
        platformChannels,
      ),
    );

    final fromIsolateStream = fromIsolate.asBroadcastStream();
    final subscription = fromIsolateStream.listen((message) {
      if (message is SendPort) {
        toIsolateCompleter.complete(message);
      }
    });
    final toIsolate = await toIsolateCompleter.future;
    await subscription.cancel();

    final isolateMessenger =
        IsolateMessenger(fromIsolateStream, toIsolate.send);

    // Initialize platform channel
    WidgetsFlutterBinding.ensureInitialized();
    MethodChannelMiddleware(
      generateId: Uuid().v4,
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      sendEvent: isolateMessenger.add,
      channels: platformChannels,
    );

    return IsolateManagerImpl(
      IsolateWrapperImpl(isolate),
      isolateMessenger,
    );
  }

  static Future<void> _runInIsolate(_IsolateSetup setup) async {
    final toIsolate = ReceivePort();
    final toIsolateStream = toIsolate.asBroadcastStream();
    setup.fromIsolate.send(toIsolate.sendPort);
    final isolateMessenger =
        IsolateMessenger(toIsolateStream, setup.fromIsolate.send);

    // Initialize platform channel in isolate
    IsolateBinding();
    IsolatedPlatformChannelMiddleware(
      channels: setup.platformChannels,
      platformMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      generateId: Uuid().v4,
      sendEvent: isolateMessenger.add,
    );
    setup.task(isolateMessenger, setup.userInitializer);
  }
}

class _IsolateSetup {
  _IsolateSetup(
      this.fromIsolate, this.task, this.userInitializer, this.platformChannels);

  final SendPort fromIsolate;
  final Initializer userInitializer;
  final IsolateRun task;
  final List<String> platformChannels;
}
