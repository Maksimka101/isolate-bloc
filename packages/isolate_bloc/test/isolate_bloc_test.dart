import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc_test/isolate_bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'blocs/counter_blocs.dart';
import 'initializers.dart';

class MockBlocObserver extends Mock implements IsolateBlocObserver {}

void main() {
  group("Full bloc's infrastructure test", () {
    test('Test simple operations like register, create, add and listen.',
        () async {
      final states = [0, -1];
      final actualStates = <int>[];
      await initializeMock(Initializers.counterTest);
      // ignore: close_sinks
      final counterBloc = createBloc<CounterBloc, int>();
      final complete = Completer();
      counterBloc.listen((state) {
        actualStates.add(state);
        if (states.length == actualStates.length) {
          complete.complete();
        }
      });
      counterBloc.add(CountEvent.decrement);
      await complete.future;
      expect(
        actualStates,
        states,
        reason: 'counter bloc have unexpected state',
      );
    });

    test('returns correct initial state', () async {
      await initializeMock(Initializers.counterTest);
      final bloc = createBloc<CounterBloc, int>();
      expect(bloc.state, 0,
          reason:
              "BlocWrapper's initial state isn't the same as Bloc's initial state");
    });

    test('Test `getBloc`', () async {
      final states = [0, -1, 0, 1, 2, 3];
      var wrapperHistory = <int>[];
      await initializeMock(Initializers.injectionTest);
      // ignore: close_sinks
      final counterBloc = createBloc<CounterBloc, int>();
      // ignore: close_sinks
      final historyWithInjector =
          createBloc<CounterHistoryWrapperInjector, List<int>>();
      final completer = Completer();
      historyWithInjector.listen((wrapperState) {
        wrapperHistory = wrapperState;
        if (states.length == wrapperState.length) {
          completer.complete();
        }
      });

      counterBloc.add(CountEvent.decrement);
      counterBloc.add(CountEvent.increment);
      counterBloc.add(CountEvent.increment);
      counterBloc.add(CountEvent.increment);
      counterBloc.add(CountEvent.increment);
      await completer.future;
      expect(wrapperHistory, states);
    });

    test('Test implicit bloc creation with `getBloc`', () async {
      /// CounterIncrementerBloc create bloc by calling getBloc and add increment event.
      /// createBloc<CounterBloc, int> must provide bloc which was created by CounterIncrementBloc
      /// and this bloc must have the same states.
      await initializeMock(Initializers.injectionTest);
      createBloc<CounterIncrementerBloc, int>();
      createBloc<CounterIncrementerBloc, int>();
      createBloc<CounterBloc, int>();
      final bloc = createBloc<CounterBloc, int>();
      bloc.skip(1);
      const matcher = 2;
      final actual = await createBloc<CounterBloc, int>().skip(1).first;
      print('main');
      expect(actual, matcher);
    });
  });
}
