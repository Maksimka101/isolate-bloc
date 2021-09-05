import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/mock_isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/mock/mock_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/mock/mock_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/mock_method_channel_middleware.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import '../../../../blocs/simple_cubit.dart';

void main() {
  late IIsolateMessenger isolateMessenger;
  late IMethodChannelMiddleware methodChannelMiddleware;

  late UIIsolateManager uiIsolateManager;

  Future<void> setDefaultInitialStates({
    Stream<IsolateBlocEvent>? eventsStream,
  }) async {
    await setInitialStates(
      uiIsolateManager: uiIsolateManager,
      isolateMessenger: isolateMessenger,
      initialStates: {SimpleCubit: 0},
      eventsStream: eventsStream,
    );
  }

  setUp(() {
    isolateBlocIdGenerator = Uuid().v4;
    isolateMessenger = MockIsolateMessenger();
    methodChannelMiddleware = MockMethodChannelMiddleware();

    registerFallbackValue(MockCreateIsolateBlocEvent());
    registerFallbackValue(MockIsolateBlocEvent());

    uiIsolateManager = UIIsolateManager(
      IsolateCreateResult(MockIsolateWrapper(), isolateMessenger),
      methodChannelMiddleware,
    );
  });

  group('Test public methods', () {
    test('initialize method', () {
      when(() => isolateMessenger.messagesStream).thenAnswer(
        (_) => Stream.empty(),
      );
      // Test initialize doesn't throw exceptions
      uiIsolateManager.initialize();
    });

    test('initial states receiving', () async {
      await setDefaultInitialStates();
    });

    test('createBlock method', () async {
      await setDefaultInitialStates();

      uiIsolateManager.createBloc<SimpleCubit, int>();
      verify(() => isolateMessenger.send(any())).called(1);
    });
  });
  group('Test IsolateBlocWrapper provided by createBloc method', () {
    test('initial state', () async {
      await setDefaultInitialStates();

      final wrapper = uiIsolateManager.createBloc<SimpleCubit, int>();
      expect(wrapper.state, 0);
    });

    test('do not send event when IsolateBlocBase is not created', () async {
      await setDefaultInitialStates();

      final wrapper = uiIsolateManager.createBloc<SimpleCubit, int>();
      wrapper.add('test');

      await Future.delayed(Duration(milliseconds: 1));
      verifyNever(() => isolateMessenger.send(MockIsolateBlocTransitionEvent()));
    });

    test('send event when IsolateBlocBase is created', () async {
      isolateBlocIdGenerator = () => '';
      final streamController = StreamController<IsolateBlocEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      final wrapper = uiIsolateManager.createBloc<SimpleCubit, int>();
      streamController.add(IsolateBlocCreatedEvent(''));
      await Future.delayed(Duration(milliseconds: 1));
      wrapper.add('test');
      await Future.delayed(Duration(milliseconds: 1));

      verify(() => isolateMessenger.send(IsolateBlocTransitionEvent('', 'test'))).called(1);
    });

    test('send unsent events', () async {
      isolateBlocIdGenerator = () => '';
      final streamController = StreamController<IsolateBlocEvent>();
      await setDefaultInitialStates(eventsStream: streamController.stream);

      final wrapper = uiIsolateManager.createBloc<SimpleCubit, int>();
      wrapper.add('test');
      streamController.add(IsolateBlocCreatedEvent(''));
      await Future.delayed(Duration(milliseconds: 1));

      verify(() => isolateMessenger.send(IsolateBlocTransitionEvent('', 'test'))).called(1);
    });
  });
}

Future<void> setInitialStates({
  required UIIsolateManager uiIsolateManager,
  required IIsolateMessenger isolateMessenger,
  required InitialStates initialStates,
  Stream<IsolateBlocEvent>? eventsStream,
}) async {
  when(() => isolateMessenger.messagesStream).thenAnswer(
    (_) async* {
      yield IsolateBlocsInitialized(initialStates);
      if (eventsStream != null) {
        yield* eventsStream;
      }
    },
  );

  uiIsolateManager.initialize();

  await Future.delayed(Duration(milliseconds: 1));
}
