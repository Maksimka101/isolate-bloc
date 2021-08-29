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
    this.fromIsolateBloc,
    this.task,
    this.userInitializer,
    this.methodChannels,
  );

  final SendPort fromIsolateBloc;
  final Initializer userInitializer;
  final IsolateRun task;
  final MethodChannels methodChannels;
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

    final fromIsolateBloc = ReceivePort();
    final toIsolateBlocCompleter = Completer<SendPort>();
    final isolate = await Isolate.spawn<_IsolateSetup>(
      _runInIsolate,
      _IsolateSetup(
        fromIsolateBloc.sendPort,
        isolateRun,
        initializer,
        methodChannels,
      ),
      errorsAreFatal: false,
    );

    final fromIsolateBlocStream = fromIsolateBloc.asBroadcastStream();
    final subscription = fromIsolateBlocStream.listen((message) {
      if (message is SendPort) {
        toIsolateBlocCompleter.complete(message);
      }
    });
    final toIsolate = await toIsolateBlocCompleter.future;
    await subscription.cancel();

    final isolateMessenger = IsolateMessenger(
      fromIsolateBlocStream.cast<Object>(),
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
    final toUiIsolate = ReceivePort();
    final toUiIsolateStream = toUiIsolate.asBroadcastStream();
    setup.fromIsolateBloc.send(toUiIsolate.sendPort);
    final isolateMessenger = IsolateMessenger(
      toUiIsolateStream.cast<Object>(),
      setup.fromIsolateBloc.send,
    );

    // Initialize platform channel in isolate
    IsolateBinding();
    IsolatedPlatformChannelMiddleware(
      channels: setup.methodChannels,
      platformMessenger: ServicesBinding.instance!.defaultBinaryMessenger,
      generateId: const Uuid().v4,
      sendEvent: isolateMessenger.add,
    );
    setup.task(isolateMessenger, setup.userInitializer);
  }
}
