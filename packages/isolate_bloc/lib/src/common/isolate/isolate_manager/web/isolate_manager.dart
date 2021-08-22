import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

import '../../bloc_manager.dart';
import 'web_isolate_wrapper.dart';

/// Web [IsolateManagerFactory]'s implementation.
/// It doesn't creates [Isolate].
class WebIsolateManagerFactory implements IsolateManagerFactory {
  @override
  Future<IsolateManager> create(
    IsolateRun run,
    Initializer initializer,
    MethodChannels methodChannels,
  ) async {
    final fromIsolate = StreamController<Object>.broadcast();
    final toIsolate = StreamController<Object>.broadcast();
    final sendFromIsolate = fromIsolate.add;
    final sendToIsolate = toIsolate.add;
    final toIsolateStream = toIsolate.stream;
    final fromIsolateStream = fromIsolate.stream;

    final isolateMessenger = IsolateMessenger(fromIsolateStream, sendToIsolate);

    // this function run isolated function (IsolateRun)
    run(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateManager(
      WebIsolateWrapper(),
      isolateMessenger,
    );
  }
}
