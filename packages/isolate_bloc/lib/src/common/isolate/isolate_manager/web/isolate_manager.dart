import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_messenger.dart';

import '../../bloc_manager.dart';
import 'web_isolate_wrapper.dart';

/// Web [IsolateManager]'s implementation.
/// It doesn't creates [Isolate].
class IsolateManagerImpl extends IsolateManager {
  IsolateManagerImpl(IsolateWrapper isolate, IsolateMessenger messenger)
      : super(isolate, messenger);

  static Future<IsolateManagerImpl> createIsolate(
    IsolateRun run,
    Initializer initializer, [
    List<String> platformChannels,
  ]) async {
    final fromIsolate = StreamController<Object>.broadcast();
    final toIsolate = StreamController<Object>.broadcast();
    final sendFromIsolate = fromIsolate.add;
    final sendToIsolate = toIsolate.add;
    final toIsolateStream = toIsolate.stream;
    final fromIsolateStream = fromIsolate.stream;

    final isolateMessenger = IsolateMessenger(fromIsolateStream, sendToIsolate);

    // this function run isolated function (IsolateRun)
    run(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateManagerImpl(
      WebIsolateWrapper(),
      isolateMessenger,
    );
  }
}
