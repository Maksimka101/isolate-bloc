import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../blocs/simple_cubit.dart';
import 'api_wrappers_test.dart';

void main() {
  late IsolateManager isolateManager;

  setUp(() {
    isolateManager = _MockIsolateManager();
    IsolateManager.instance = isolateManager;
  });

  group("Test 'register' function", () {
    test("register with initialized 'IsolateManager'", () {
      when(() => isolateManager.registerBloc(any()))
          .thenAnswer((invocation) {});

      register<SimpleCubit, int>(create: SimpleCubit.new);
    });

    test("register with uninitialized 'IsolateManager'", () {
      IsolateManager.instance = null;

      dynamic error;
      try {
        register<SimpleCubit, int>(create: SimpleCubit.new);
      } catch (e) {
        error = e;
      }

      expect(error, isA<IsolateManagerUnInitialized>());
      error.toString();
    });
  });

  group("Test 'getBloc' function", () {
    test("getBloc with initialized 'IsolateManager'", () {
      when(
        () => isolateManager.getBlocWrapper<SimpleCubit, int>(),
      ).thenReturn(MockIsolateBlocWrapper<int>());
      getBloc<SimpleCubit, int>();
    });

    test("getBloc with uninitialized 'IsolateManager'", () {
      IsolateManager.instance = null;

      dynamic error;
      try {
        getBloc();
      } catch (e) {
        error = e;
      }

      expect(error, isA<IsolateManagerUnInitialized>());
    });
  });
}

class _MockIsolateManager extends Mock implements IsolateManager {}
