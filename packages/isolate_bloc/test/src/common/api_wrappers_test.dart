import 'package:combine/combine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../blocs/simple_cubit.dart';

void main() {
  late UIIsolateManager uiIsolateManager;

  setUp(() {
    setTestIsolateFactory(WebIsolateFactory());
    uiIsolateManager = _MockUIIsolateManager();

    UIIsolateManager.instance = uiIsolateManager;
  });
  tearDownAll(cleanTestIsolateFactory);

  group('test `createBloc`', () {
    test('test with initialized `UIIsolateManager`', () {
      when(() => uiIsolateManager.createIsolateBloc<SimpleCubit, int>())
          .thenReturn(MockIsolateBlocWrapper<int>());
      createBloc<SimpleCubit, int>();

      verify(
        () => uiIsolateManager.createIsolateBloc<SimpleCubit, int>(),
      ).called(1);
    });

    test('test with uninitialized `UIIsolateManager`', () {
      UIIsolateManager.instance = null;

      dynamic error;
      try {
        createBloc();
      } catch (e) {
        error = e;
      }

      expect(error, isA<UIIsolateManagerUnInitialized>());
      error.toString();
    });
  });

  test("'initialize' function disposes previous 'UIIsolateManager'", () async {
    when(() => uiIsolateManager.dispose()).thenAnswer((invocation) async {});

    await initialize(_initialize);

    verify(() => uiIsolateManager.dispose()).called(1);
  });

  test('test `initialize` function #2', () async {
    expect(initialize(_initialize), throwsA(isNotNull));
  });
}

void _initialize() {}

class MockIsolateBlocWrapper<T> extends Mock implements IsolateBlocWrapper<T> {}

class _MockUIIsolateManager extends Mock implements UIIsolateManager {}
