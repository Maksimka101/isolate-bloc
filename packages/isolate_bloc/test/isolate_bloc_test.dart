// ignore_for_file: no-empty-bloc
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

import 'initializers/counter_bloc_initializer.dart';
import 'initializers/simple_initializer.dart';
import 'isolate_blocs/increment_cubit.dart';
import 'isolate_blocs/simple_cubit.dart';
import 'test_utils/initialize.dart';

void main() {
  group('Test isolate_bloc on native platform', () {
    testInitializePlatform(TestInitializePlatform.native);
    runTests();
  });
  group('Test isolate_bloc on web platform', () {
    testInitializePlatform(TestInitializePlatform.web);
    runTests();
  });
}

void runTests() {
  group("Test basic functionality such as create bloc, add event, receive state", () {
    test(
      "Test that initialize function works fine and doesn't terminate process",
      () async {
        await testInitialize(simpleBlocInitializer);
        expect(true, true);
      },
    );

    test(
      "Test that bloc successfully created, "
      "emit it's initial state and this state received.",
      () async {
        await testInitialize(simpleBlocInitializer);
        final blocWrapper = createBloc<SimpleCubit, String>();
        var valueReceived = false;
        blocWrapper.stream.listen((_) {
          valueReceived = true;
        });
        // expect that next task in the event loop will be my listen function so i wait for this task.
        // and it is really works! just try to comment this line, run test and it will fail.
        await Future.delayed(Duration.zero);
        expect(
          valueReceived,
          true,
          reason: "Didn't receive initial state immediately",
        );
      },
    );

    test("Test that bloc emits its initial state", () async {
      await testInitialize(simpleBlocInitializer);
      final blocWrapper = createBloc<SimpleCubit, String>();
      final initialState = await blocWrapper.stream.first;
      expect(
        initialState,
        'empty',
        reason: "First simple bloc's state must be an empty word",
      );
    });

    test("Test that bloc emits it's not initial state", () async {
      await testInitialize(simpleBlocInitializer);
      final blocWrapper = createBloc<SimpleCubit, String>();
      blocWrapper.add(Object());
      final stateFuture = blocWrapper.stream.skip(1).first;
      var stateReceived = false;
      // wait for bloc's response
      // ignore: unawaited_futures
      Future.delayed(const Duration(milliseconds: 10)).then((_) {
        expect(
          stateReceived,
          true,
          reason: "Bloc's not initial state is not received",
        );
      });
      await stateFuture;
      stateReceived = true;
    });

    test("Test that bloc emits state with data on some event", () async {
      await testInitialize(simpleBlocInitializer);
      final blocWrapper = createBloc<SimpleCubit, String>();
      blocWrapper.add(Object());
      final state = await blocWrapper.stream.skip(1).first;
      expect(state, 'data', reason: "Bloc's not initial state is not right");
    });

    test("Test that state received on every event", () async {
      await testInitialize(counterBlocInitializer);
      final blocWrapper = createBloc<CounterCubit, int>();
      const eventsCount = 4;
      var statesReceivedCount = 0;
      blocWrapper.stream.listen((state) {
        statesReceivedCount++;
      });
      for (int i = 0; i < eventsCount; i++) {
        blocWrapper.add(true);
      }
      // wait while all states will be received
      await Future.delayed(const Duration(milliseconds: 10));
      expect(
        statesReceivedCount,
        eventsCount + 1,
        reason: "Number of received states doesn't correspond to the "
            "number of events",
      );
    });

    test("Test that bloc's state received in right order", () async {
      await testInitialize(counterBlocInitializer);
      final blocWrapper = createBloc<CounterCubit, int>();
      final expectOrder = [0, 1, 2, 1];
      // Point to the index of the next state to check
      var receivedStatePointer = 0;
      blocWrapper
        ..add(true)
        ..add(true)
        ..add(false)
        ..stream.take(3)
        ..stream.listen((state) {
          expect(
            expectOrder[receivedStatePointer++],
            state,
            reason: "Looks like state received in wrong order",
          );
        });
    });

    test("Test that IsolateBlocWrapper closed when call close()", () async {
      await testInitialize(simpleBlocInitializer);
      final blocWrapper = createBloc<SimpleCubit, String>();
      var streamClosed = false;
      blocWrapper.stream.listen((_) {}, onDone: () {
        streamClosed = true;
      });
      await blocWrapper.close();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(streamClosed, true);
    });
  });

  group("Some more complex tests", () {
    test(
      "Test that two bloc of the same type actually are different "
      "and emits different states",
      () async {
        await testInitialize(counterBlocInitializer);
        final bloc1 = createBloc<CounterCubit, int>();
        final bloc2 = createBloc<CounterCubit, int>();
        bloc1.add(true);
        bloc1.stream.skip(1).listen((state) {
          expect(
            state,
            1,
            reason: "Received wrong state from another bloc "
                "or this bloc receive event for another bloc",
          );
        });
        bloc2.add(false);
        bloc2.stream.skip(1).listen((state) {
          expect(
            state,
            -1,
            reason: "Received wrong state from another bloc "
                "or this bloc receive event for another bloc",
          );
        });
        // wait for responses from blocs
        await Future.delayed(const Duration(milliseconds: 10));
      },
    );
  });
}
