import 'dart:async';
import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/abstract_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

/// Web [IsolateFactory]'s implementation.
/// It doesn't create [Isolate].
class WebIsolateFactory implements IsolateFactory {
  @override
  Future<IsolateCreateResult> create(
    IsolateRun run,
    Initializer initializer,
    MethodChannels methodChannels,
  ) async {
    final fromIsolate = StreamController.broadcast();
    final toIsolate = StreamController.broadcast();
    final sendFromIsolate = fromIsolate.add;
    final sendToIsolate = toIsolate.add;
    final toIsolateStream = toIsolate.stream;
    final fromIsolateStream = fromIsolate.stream;

    final isolateMessenger = IsolateMessenger(fromIsolateStream, sendToIsolate);

    // this function run isolated function (IsolateRun)
    run(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateCreateResult(
      WebIsolateWrapper(),
      isolateMessenger,
    );
  }
}