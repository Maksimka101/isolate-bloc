import 'dart:async';
import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate_messenger/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_setup.dart';

/// Web [IIsolateFactory]'s implementation.
/// Used in web environment because it doesn't create [Isolate].
class WebIsolateFactory implements IIsolateFactory {
  /// Simply creates two [IsolateMessenger]s, runs [isolateRun]
  /// and returns [WebIsolateWrapper].
  @override
  Future<IsolateCreateResult> create(
    IsolateRun isolateRun,
    Initializer initializer,
    MethodChannels methodChannels,
  ) async {
    // Will be closed by [WebIsolateWrapper.kill].
    // ignore: close_sinks
    final fromIsolate = StreamController.broadcast();
    // ignore: close_sinks
    final toIsolate = StreamController.broadcast();
    final sendFromIsolate = fromIsolate.add;
    final sendToIsolate = toIsolate.add;
    final toIsolateStream = toIsolate.stream;
    final fromIsolateStream = fromIsolate.stream;

    final isolateMessenger = IsolateMessenger(fromIsolateStream, sendToIsolate);

    // This function run isolated function (IsolateRun).
    // ignore: unawaited_futures
    _isolateRun(
      IsolateMessenger(toIsolateStream, sendFromIsolate),
      isolateRun,
      initializer,
    );

    return IsolateCreateResult(
      WebIsolateWrapper(
        fromIsolate: fromIsolate,
        toIsolate: toIsolate,
      ),
      isolateMessenger,
    );
  }

  /// Schedules [isolateRun] to run after [UIIsolateManager] is created.
  ///
  /// Otherwise [IsolateBlocsInitialized] event won't be handled by [UIIsolateManager].
  Future<void> _isolateRun(
    IIsolateMessenger isolateMessenger,
    IsolateRun isolateRun,
    Initializer initializer,
  ) async {
    await Future.delayed(Duration.zero);
    isolateRun(isolateMessenger, initializer);
  }
}
