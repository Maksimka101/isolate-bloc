import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/mock/mock_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/mock_isolated_method_channel_middleware.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../blocs/counter_bloc.dart';
import '../../../../blocs/simple_cubit.dart';

void main() {
  late IsolateManager isolateManager;
  late IIsolateMessenger isolateMessenger;
  late IIsolatedMethodChannelMiddleware methodChannelMiddleware;
  late Initializer userInitializer;

  Future<void> initializeManager({
    Stream<IsolateBlocEvent>? eventsStream,
  }) async {
    initializeMessenger(
      isolateMessenger: isolateMessenger,
      eventsStream: eventsStream,
    );

    await isolateManager.initialize();
  }

  Future<B> createBloc<B extends IsolateBlocBase<Object?, S>, S>({
    required B Function() create,
    required StreamController<IsolateBlocEvent> controller,
    String? id,
  }) async {
    late B createdCubit;
    isolateManager.register<B, S>(() => createdCubit = create());

    controller.add(CreateIsolateBlocEvent(SimpleCubit, id ?? 'id'));
    await Future.delayed(Duration(milliseconds: 1));

    return createdCubit;
  }

  setUp(() {
    isolateMessenger = MockIsolateMessenger();
    methodChannelMiddleware = MockIsolatedMethodChannelMiddleware();
    userInitializer = () {};

    isolateManager = IsolateManager(
      messenger: isolateMessenger,
      userInitializer: () => userInitializer(),
      methodChannelMiddleware: methodChannelMiddleware,
    );
  });

  group('Test IsolateManager methods', () {
    group('Initialization', () {
      setUp(() {
        initializeMessenger(isolateMessenger: isolateMessenger);
      });

      test('user initializer called on initialize', () async {
        var initialized = false;
        userInitializer = () => initialized = true;

        await initializeManager();

        expect(initialized, isTrue);
      });

      test('catch exception in user initializer function while initialization', () async {
        userInitializer = () => throw Exception();

        // Throws exception in debug mode
        expect(initializeManager(), throwsA((e) => e is InitializerException));
      });

      test('IsolateBlocInitialized event is sent after initialization', () async {
        await initializeManager();

        verify(() => isolateMessenger.send(IsolateBlocsInitialized({}))).called(1);
      });
    });

    group('Register', () {
      test('register method and bloc creating', () async {
        final controller = StreamController<IsolateBlocEvent>();
        await initializeManager(eventsStream: controller.stream);

        SimpleCubit? createdCubit;
        isolateManager.register<SimpleCubit, int>(() => createdCubit = SimpleCubit());
        expect(createdCubit, isNotNull);

        controller.add(CreateIsolateBlocEvent(SimpleCubit, 'id'));
        await Future.delayed(Duration(milliseconds: 1));

        expect(createdCubit!.id, 'id');
      });

      test('register with initial state', () async {
        final controller = StreamController<IsolateBlocEvent>();
        await initializeManager(eventsStream: controller.stream);

        SimpleCubit? createdCubit;
        isolateManager.register<SimpleCubit, int>(
          () => createdCubit = SimpleCubit(),
          initialState: 0,
        );
        expect(createdCubit, isNull);

        controller.add(CreateIsolateBlocEvent(SimpleCubit, 'id'));
        await Future.delayed(Duration(milliseconds: 1));

        expect(createdCubit, isNotNull);
      });

      test('all initial states are registered', () async {
        final controller = StreamController<IsolateBlocEvent>();

        isolateManager.register<CounterBloc, int>(() => CounterBloc());
        isolateManager.register<SimpleCubit, int>(
          () => SimpleCubit(),
          initialState: 500,
        );

        await initializeManager(eventsStream: controller.stream);

        verify(
          () => isolateMessenger.send(IsolateBlocsInitialized({
            SimpleCubit: 500,
            CounterBloc: 0,
          })),
        ).called(1);
      });
    });
  });

  group('Test IsolateBloc provided by IsolateManager', () {
    test('emit state', () async {
      final controller = StreamController<IsolateBlocEvent>();
      await initializeManager(eventsStream: controller.stream);

      final simpleCubit = await createBloc(
        create: () => SimpleCubit(),
        controller: controller,
      );

      simpleCubit.add('');
      await Future.delayed(Duration(milliseconds: 1));

      verify(() => isolateMessenger.send(IsolateBlocTransitionEvent('id', 1))).called(1);
    });

    test('receive event', () async {
      final controller = StreamController<IsolateBlocEvent>();
      await initializeManager(eventsStream: controller.stream);

      final simpleCubit = await createBloc(
        create: () => SimpleCubit(),
        controller: controller,
      );

      controller.add(IsolateBlocTransitionEvent('id', ''));
      await Future.delayed(Duration(milliseconds: 1));

      // State updated when event is received
      expect(simpleCubit.state, 1);
    });

    test('emit unsent states', () async {
      final controller = StreamController<IsolateBlocEvent>();
      await initializeManager(eventsStream: controller.stream);

      late CounterBloc bloc;
      isolateManager.register<CounterBloc, int>(() => bloc = CounterBloc());

      bloc.add(CounterEvent.increment);
      bloc.add(CounterEvent.increment);

      // state didn't changed because bloc didn't connected
      expect(bloc.state, 0);

      expect(bloc.stream, emitsInOrder([1, 2]));

      controller.add(CreateIsolateBlocEvent(CounterBloc, 'id'));
      await Future.delayed(Duration(milliseconds: 1));

      expect(bloc.state, 2);
    });
  });

  group('Test getBlocWrapper method', () {
    test(
      'get bloc wrapper for registered, unregistered '
      'and registered with initial state bloc',
      () async {
        final controller = StreamController<IsolateBlocEvent>();

        userInitializer = () {
          var cubitWrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
          expect(cubitWrapper, isNotNull);
          // Bloc wrapper of unregistered bloc has no state
          expect(cubitWrapper.state, isNull);

          SimpleCubit? cubit;
          isolateManager.register<SimpleCubit, int>(() => cubit = SimpleCubit());
          expect(cubit, isNotNull);
          cubitWrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
          expect(cubitWrapper, isNotNull);
          // Bloc wrapper of registered bloc has a state
          expect(cubitWrapper.state, 0);

          // test wit initial state
          CounterBloc? bloc;
          isolateManager.register<CounterBloc, int>(
            () => bloc = CounterBloc(),
            initialState: 0,
          );
          expect(bloc, isNull);

          var blocWrapper = isolateManager.getBlocWrapper<CounterBloc, int>();
          expect(blocWrapper, isNotNull);
          expect(blocWrapper.state, 0);
        };

        await initializeManager(eventsStream: controller.stream);
      },
    );

    group('Test IsolateBlocWrapper provided by getBlocWrapper', () {
      // TODO: take tests from ui_isolate_manager_test
    });
  });
}

void initializeMessenger({
  required IIsolateMessenger isolateMessenger,
  Stream<IsolateBlocEvent>? eventsStream,
}) {
  when(() => isolateMessenger.messagesStream).thenAnswer(
    (_) async* {
      if (eventsStream != null) {
        yield* eventsStream;
      }
    },
  );
}
