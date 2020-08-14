import 'dart:isolate';

import 'package:isolate_bloc/isolate_bloc.dart';

import 'mock_isolate_wrapper.dart';

/// [IsolateManager] implementation for tests.
/// Have all [IsolateManagerImpl]'s restrictions.
class MockIsolateManager extends IsolateManager {
  MockIsolateManager(IsolateWrapper isolate, IsolateMessenger messenger)
      : super(isolate, messenger);

  /// Create [MockIsolateManager] object.
  static Future<MockIsolateManager> createIsolate(
      IsolateRun run, Initializer initializer) async {
    var fromIsolate = ReceivePort();
    var toIsolate = ReceivePort();
    var sendFromIsolate = fromIsolate.sendPort.send;
    var sendToIsolate = toIsolate.sendPort.send;
    var toIsolateStream = toIsolate.asBroadcastStream();
    var fromIsolateStream = fromIsolate.asBroadcastStream();

    // this function run isolated function (IsolateRun)
    run(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return MockIsolateManager(
      MockIsolateWrapper(),
      IsolateMessenger(
        fromIsolateStream,
        sendToIsolate,
      ),
    );
  }
}
