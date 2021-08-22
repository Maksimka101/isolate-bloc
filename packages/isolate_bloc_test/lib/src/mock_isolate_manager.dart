import 'dart:isolate';

import 'package:isolate_bloc/isolate_bloc.dart';

import 'mock_isolate_wrapper.dart';

/// [IsolateManager] implementation for tests.
/// Have all IO [IsolateManager] restrictions.
class MockIsolateManagerFactory extends IsolateManagerFactory {
  /// Create mock [IsolateManager] object.
  @override
  Future<IsolateManager> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels) async {
    var fromIsolate = ReceivePort();
    var toIsolate = ReceivePort();
    var sendFromIsolate = fromIsolate.sendPort.send;
    var sendToIsolate = toIsolate.sendPort.send;
    var toIsolateStream = toIsolate.asBroadcastStream().cast<Object>();
    var fromIsolateStream = fromIsolate.asBroadcastStream().cast<Object>();

    // this function run isolated function (IsolateRun)
    isolateRun(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateManager(
      MockIsolateWrapper(),
      IsolateMessenger(
        fromIsolateStream,
        sendToIsolate,
      ),
    );
  }
}
