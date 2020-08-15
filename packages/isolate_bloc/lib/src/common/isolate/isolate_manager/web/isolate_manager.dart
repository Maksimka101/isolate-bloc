import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_messenger.dart';

import '../../bloc_manager.dart';
import 'web_isolate_wrapper.dart';

/// Web [IsolateManager]'s implementation.
/// It doesn't creates [Isolate].
class IsolateManagerImpl extends IsolateManager {
  IsolateManagerImpl(IsolateWrapper isolate, IsolateMessenger messenger,
      [List<String> platformChannels])
      : super(isolate, messenger);

  static Future<IsolateManagerImpl> createIsolate(
      IsolateRun run, Initializer initializer) async {
    var fromIsolate = StreamController<Object>.broadcast();
    var toIsolate = StreamController<Object>.broadcast();
    var sendFromIsolate = fromIsolate.add;
    var sendToIsolate = toIsolate.add;
    var toIsolateStream = toIsolate.stream;
    var fromIsolateStream = fromIsolate.stream;

    var isolateMessenger = IsolateMessenger(fromIsolateStream, sendToIsolate);

    // this function run isolated function (IsolateRun)
    run(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateManagerImpl(
      WebIsolateWrapper(),
      isolateMessenger,
    );
  }
}
