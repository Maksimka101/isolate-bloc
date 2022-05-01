import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:mocktail/mocktail.dart';

abstract class _MockIsolateRun {
  FutureOr<void> call(IIsolateMessenger messenger, Initializer initializer);
}

abstract class _MockInitializer {
  FutureOr<dynamic> call();
}

class MockIsolateRun extends Mock implements _MockIsolateRun {}

class MockInitializer extends Mock implements _MockInitializer {}
