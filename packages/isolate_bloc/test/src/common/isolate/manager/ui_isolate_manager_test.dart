import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import '../../../../mock/mock_isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import '../../../../blocs/simple_cubit.dart';
import '../../../../mock/mock_isolate_messenger.dart';
import '../../../../mock/mock_isolate_wrapper.dart';

void main() {
  late IIsolateMessenger isolateMessenger;

  late UIIsolateManager uiIsolateManager;
  late IIsolateWrapper isolateWrapper;

  /// Sets initial states to the `uiIsolateManager`
  ///
  /// In `eventsStream` is provided yields them to the `isolatedMessenger.messagesStream`
  Future<void> setInitialStates({
    required UIIsolateManager uiIsolateManager,
    required IIsolateMessenger isolateMessenger,
    required InitialStates initialStates,
    Stream<IsolateEvent>? eventsStream,
  }) async {
    when(() => isolateMessenger.messagesStream).thenAnswer(
      (_) async* {
        yield IsolateBlocsInitialized(initialStates);
        if (eventsStream != null) {
          yield* eventsStream;
        }
      },
    );

    await uiIsolateManager.initialize();

    await Future.delayed(const Duration(milliseconds: 1));
  }

  Future<void> setDefaultInitialStates({
    Stream<IsolateEvent>? eventsStream,
  }) async {
    await setInitialStates(
      uiIsolateManager: uiIsolateManager,
      isolateMessenger: isolateMessenger,
      initialStates: {SimpleCubit: 0},
      eventsStream: eventsStream,
    );
  }

  setUp(() {
    isolateMessenger = MockIsolateMessenger();
    isolateBlocIdGenerator = const Uuid().v4;
    isolateWrapper = MockIsolateWrapper();

    registerFallbackValue(MockCreateIsolateBlocEvent());
    registerFallbackValue(MockIsolateBlocEvent());

    uiIsolateManager = UIIsolateManager(
      IsolateCreateResult(isolateWrapper, isolateMessenger),
    );
  });

  group('Test public methods', () {
    test('initialize method', () {
      when(() => isolateMessenger.messagesStream).thenAnswer(
        (_) => const Stream.empty(),
      );
      // Test initialize doesn't throw exceptions
      uiIsolateManager.initialize();
    });

    test('initial states receiving', () async {
      await setDefaultInitialStates();
    });

    test('createBlock method', () async {
      await setDefaultInitialStates();

      uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      verify(() => isolateMessenger.send(any())).called(1);
    });

    test('test dispose', () async {
      await setDefaultInitialStates();

      await uiIsolateManager.dispose();

      verify(() => isolateWrapper.kill()).called(1);
    });
  });

  group('Test IsolateBlocWrapper provided by createBloc method', () {
    setUp(() {
      isolateBlocIdGenerator = () => '';
    });

    test('initial state', () async {
      await setDefaultInitialStates();

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      expect(wrapper.state, 0);
    });

    test('do not send event when IsolateBlocBase is not created', () async {
      await setDefaultInitialStates();

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      wrapper.add('test');

      await Future.delayed(const Duration(milliseconds: 1));
      verifyNever(
          () => isolateMessenger.send(MockIsolateBlocTransitionEvent()));
    });

    test('send event when IsolateBlocBase is created', () async {
      final streamController = StreamController<IsolateEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      streamController.add(IsolateBlocCreatedEvent(''));
      await Future.delayed(const Duration(milliseconds: 1));
      wrapper.add('test');
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() =>
              isolateMessenger.send(IsolateBlocTransitionEvent('', 'test')))
          .called(1);
    });

    test('send unsent events', () async {
      final streamController = StreamController<IsolateEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      wrapper.add('test');
      streamController.add(IsolateBlocCreatedEvent(''));
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() =>
              isolateMessenger.send(IsolateBlocTransitionEvent('', 'test')))
          .called(1);
    });

    test('close IsolateBlocWrapper closes IsolateBlocBase', () async {
      await setDefaultInitialStates();

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      await wrapper.close();
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() => isolateMessenger.send(CloseIsolateBlocEvent(''))).called(1);
    });

    test('receive state from IsolateBlocBase', () async {
      final streamController = StreamController<IsolateEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      final wrapper = uiIsolateManager.createIsolateBloc<SimpleCubit, int>();
      streamController.add(IsolateBlocTransitionEvent('', 100));
      await Future.delayed(const Duration(milliseconds: 1));

      expect(wrapper.state, 100);
    });
  });

  test('test unexpected IsolateBlocEvent', () async {
    dynamic exception;
    await runZonedGuarded(() async {
      final streamController = StreamController<IsolateEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      streamController.add(_UnknownIsolateBlocEvent());
    }, (e, st) {
      exception = e;
    });

    await Future.delayed(const Duration(milliseconds: 1));

    expect(exception, isA<Exception>());
  });
}

class _UnknownIsolateBlocEvent extends IsolateBlocEvent {}
