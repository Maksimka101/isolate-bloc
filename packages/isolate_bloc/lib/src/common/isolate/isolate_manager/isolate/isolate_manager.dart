import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_binding.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/io_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/isolated_platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';
import 'package:uuid/uuid.dart';


class _IsolateSetup {
  _IsolateSetup(
    this.fromIsolate,
    this.task,
    this.userInitializer,
    this.platformChannels,
  );

  final SendPort fromIsolate;
  final Initializer userInitializer;
  final IsolateRun task;
  final List<String> platformChannels;
}

/// Creates and initializes [Isolate] and [IsolateMessenger].
class IOIsolateManagerFactory implements IsolateManagerFactory {
  @override
  Future<IsolateManager> create(
    IsolateRun isolateRun,
    Initializer initializer,
    MethodChannels methodChannels,
  ) async {
    assert(
      '$initializer'.contains(' static'),
      'Initialize function must be a static or global function',
    );

    final fromIsolate = ReceivePort();
    final toIsolateCompleter = Completer<SendPort>();
    final isolate = await Isolate.spawn<_IsolateSetup>(
      _runInIsolate,
      _IsolateSetup(
        fromIsolate.sendPort,
        isolateRun,
        initializer,
        methodChannels,
      ),
      errorsAreFatal: false,
    );

    final fromIsolateStream = fromIsolate.asBroadcastStream();
    final subscription = fromIsolateStream.listen((message) {
      if (message is SendPort) {
        toIsolateCompleter.complete(message);
      }
    });
    final toIsolate = await toIsolateCompleter.future;
    await subscription.cancel();

    final isolateMessenger = IsolateMessenger(
      fromIsolateStream.cast<Object>(),
      toIsolate.send,
    );

    // Initialize platform channel
    WidgetsFlutterBinding.ensureInitialized();
    MethodChannelMiddleware(
      generateId: const Uuid().v4,
      binaryMessenger: ServicesBinding.instance!.defaultBinaryMessenger,
      sendEvent: isolateMessenger.add,
      channels: methodChannels,
    );

    return IsolateManager(
      IOIsolateWrapper(isolate),
      isolateMessenger,
    );
  }

  static Future<void> _runInIsolate(_IsolateSetup setup) async {
    final toIsolate = ReceivePort();
    final toIsolateStream = toIsolate.asBroadcastStream();
    setup.fromIsolate.send(toIsolate.sendPort);
    final isolateMessenger = IsolateMessenger(
      toIsolateStream.cast<Object>(),
      setup.fromIsolate.send,
    );

    // Initialize platform channel in isolate
    IsolateBinding();
    IsolatedPlatformChannelMiddleware(
      channels: setup.platformChannels,
      platformMessenger: ServicesBinding.instance!.defaultBinaryMessenger,
      generateId: const Uuid().v4,
      sendEvent: isolateMessenger.add,
    );
    setup.task(isolateMessenger, setup.userInitializer);
  }
}
