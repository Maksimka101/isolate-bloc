import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

import 'absent_isolate_wrapper.dart';

class MockIsolateFactory implements IIsolateFactory {
  MockIsolateFactory({
    required this.uiIsolateMessenger,
    required this.isolatedMessenger,
  });
  final IIsolateMessenger uiIsolateMessenger;
  final IIsolateMessenger isolatedMessenger;

  @override
  Future<IsolateCreateResult> create(
    IsolateRun isolateRun,
    Initializer initializer,
  ) async {
    isolateRun(isolatedMessenger, initializer);

    return IsolateCreateResult(
      AbsentIsolateWrapper(),
      uiIsolateMessenger,
    );
  }
}
