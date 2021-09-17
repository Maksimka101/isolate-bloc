import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_binding.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate/io_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate_messenger/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';
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

/// Creates and initializes [Isolate] and [IIsolateMessenger].
class IOIsolateFactory implements IIsolateFactory {
  @override
  Future<IsolateCreateResult> create(
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
      fromIsolateBlocStream,
      toIsolate.send,
    );

    // Initialize platform channel
    WidgetsFlutterBinding.ensureInitialized();
    UIMethodChannelMiddleware(
      idGenerator: const Uuid().v4,
      binaryMessenger: ServicesBinding.instance!.defaultBinaryMessenger,
      isolateMessenger: isolateMessenger,
      methodChannels: methodChannels,
    ).initialize();

    return IsolateCreateResult(
      IOIsolateWrapper(isolate),
      isolateMessenger,
    );
  }

  static Future<void> _runInIsolate(_IsolateSetup setup) async {
    final toUiIsolate = ReceivePort();
    final toUiIsolateStream = toUiIsolate.asBroadcastStream();
    setup.fromIsolateBloc.send(toUiIsolate.sendPort);
    final isolateMessenger = IsolateMessenger(
      toUiIsolateStream,
      setup.fromIsolateBloc.send,
    );

    // Initialize platform channel in isolate
    IsolateBinding();
    IsolatedMethodChannelMiddleware(
      methodChannels: setup.methodChannels,
      binaryMessenger: ServicesBinding.instance!.defaultBinaryMessenger,
      idGenerator: const Uuid().v4,
      isolateMessenger: isolateMessenger,
    ).initialize();
    
    await setup.task(isolateMessenger, setup.userInitializer);
  }
}
