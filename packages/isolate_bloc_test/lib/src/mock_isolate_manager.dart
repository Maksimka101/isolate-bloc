import 'dart:isolate';

import 'package:isolate_bloc/isolate_bloc.dart';

import 'mock_isolate_wrapper.dart';

/// [IsolateCreateResult] implementation for tests.
/// Have all IO [IsolateCreateResult] restrictions.
class MockIsolateManagerFactory extends IIsolateFactory {
  /// Create mock [IsolateCreateResult] object.
  @override
  Future<IsolateCreateResult> create(IsolateRun isolateRun, Initializer initializer, MethodChannels methodChannels) async {
    var fromIsolate = ReceivePort();
    var toIsolate = ReceivePort();
    var sendFromIsolate = fromIsolate.sendPort.send;
    var sendToIsolate = toIsolate.sendPort.send;
    var toIsolateStream = toIsolate.asBroadcastStream();
    var fromIsolateStream = fromIsolate.asBroadcastStream();

    // this function run isolated function (IsolateRun)
    isolateRun(IsolateMessenger(toIsolateStream, sendFromIsolate), initializer);

    return IsolateCreateResult(
      MockIsolateWrapper(),
      IsolateMessenger(
        fromIsolateStream,
        sendToIsolate,
      ),
    );
  }
}
