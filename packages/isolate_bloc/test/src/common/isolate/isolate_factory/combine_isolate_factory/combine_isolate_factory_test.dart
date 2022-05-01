import 'dart:async';

import 'package:combine/combine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/combine_isolate_factory/combine_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:mocktail/mocktail.dart';

abstract class _MockIsolateRun {
  FutureOr<void> call(IIsolateMessenger messenger, Initializer initializer);
}

abstract class _MockInitializer {
  FutureOr<dynamic> call();
}

class MockIsolateRun extends Mock implements _MockIsolateRun {}

class MockInitializer extends Mock implements _MockInitializer {}

class FakeIsolateMessenger extends Fake implements IIsolateMessenger {}

void main() {
  late IsolateFactory combineIsolateFactory;
  late IsolateRun isolateRun;
  late Initializer initializer;

  setUp(() {
    combineIsolateFactory = WebIsolateFactory();
    isolateRun = MockIsolateRun();
    initializer = MockInitializer();
    
    registerFallbackValue(FakeIsolateMessenger());
  });

  test('Isolate create process', () async {
    final factory = CombineIsolateFactory(combineIsolateFactory);

    await factory.create(isolateRun, initializer);

    verify(() => isolateRun(any(), initializer)).called(1);
  });

  test("Isolate create process using 'effectiveIsolate'", () async {
    setTestIsolateFactory(combineIsolateFactory);
    final factory = CombineIsolateFactory();

    await factory.create(isolateRun, initializer);

    verify(() => isolateRun(any(), initializer)).called(1);
  });
}
