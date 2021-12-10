import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import '../../../../mock/mock_isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../blocs/counter_bloc.dart';
import '../../../../blocs/simple_cubit.dart';
import '../../../../mock/mock_isolate_messenger.dart';
import '../../../../test_utils/messenger_utils.dart';

void main() {
  late IsolateManager isolateManager;
  late IIsolateMessenger isolateMessenger;
  late Initializer userInitializer;

  Future<void> initializeManager({
    Stream<IsolateEvent>? eventsStream,
  }) async {
    initializeMessenger(
      isolateMessenger: isolateMessenger,
      eventsStream: eventsStream,
    );

    await isolateManager.initialize();
  }

  Future<B> createBloc<B extends IsolateBlocBase<Object?, S>, S>({
    required B Function() create,
    required StreamController<IsolateEvent> controller,
    String? id,
  }) async {
    late B createdCubit;
    isolateManager.registerBloc<B, S>(() => createdCubit = create());

    controller.add(CreateIsolateBlocEvent(SimpleCubit, id ?? 'id'));
    await Future.delayed(const Duration(milliseconds: 1));

    return createdCubit;
  }

  setUp(() {
    isolateMessenger = MockIsolateMessenger();
    userInitializer = () {};

    isolateManager = IsolateManager(
      messenger: isolateMessenger,
      userInitializer: () => userInitializer(),
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

      test('catch exception in user initializer function while initialization',
          () async {
        userInitializer = () => throw Exception();

        // Throws exception in debug mode
        expect(initializeManager(), throwsA(isA<InitializerException>()));
      });

      test('IsolateBlocInitialized event is sent after initialization',
          () async {
        await initializeManager();

        verify(() => isolateMessenger.send(const IsolateBlocsInitialized({})))
            .called(1);
      });
    });

    group('Register', () {
      test('register method and bloc creating', () async {
        final controller = StreamController<IsolateEvent>();
        await initializeManager(eventsStream: controller.stream);

        SimpleCubit? createdCubit;
        isolateManager
            .registerBloc<SimpleCubit, int>(() => createdCubit = SimpleCubit());
        expect(createdCubit, isNotNull);

        controller.add(const CreateIsolateBlocEvent(SimpleCubit, 'id'));
        await Future.delayed(const Duration(milliseconds: 1));

        expect(createdCubit!.id, 'id');
      });

      test('register with initial state', () async {
        final controller = StreamController<IsolateEvent>();
        await initializeManager(eventsStream: controller.stream);

        SimpleCubit? createdCubit;
        isolateManager.registerBloc<SimpleCubit, int>(
          () => createdCubit = SimpleCubit(),
          initialState: 0,
        );
        expect(createdCubit, isNull);

        controller.add(const CreateIsolateBlocEvent(SimpleCubit, 'id'));
        await Future.delayed(const Duration(milliseconds: 1));

        expect(createdCubit, isNotNull);
      });

      test('all initial states are registered', () async {
        final controller = StreamController<IsolateEvent>();

        isolateManager.registerBloc<CounterBloc, int>(() => CounterBloc());
        isolateManager.registerBloc<SimpleCubit, int>(
          () => SimpleCubit(),
          initialState: 500,
        );

        await initializeManager(eventsStream: controller.stream);

        verify(
          () => isolateMessenger.send(const IsolateBlocsInitialized({
            SimpleCubit: 500,
            CounterBloc: 0,
          })),
        ).called(1);
      });

      test('create unregistered bloc', () async {
        dynamic exception;
        await runZonedGuarded(() async {
          final controller = StreamController<IsolateEvent>();
          await initializeManager(eventsStream: controller.stream);

          controller.add(const CreateIsolateBlocEvent(SimpleCubit, 'id'));
        }, (error, stack) {
          exception = error;
        });

        await Future.delayed(const Duration(milliseconds: 1));

        expect(exception, isA<BlocUnregisteredException>());
        exception.toString();
      });
    });

    test('dispose', () async {
      await initializeManager();

      await isolateManager.dispose();
    });
  });

  group('Test IsolateBloc provided by IsolateManager', () {
    test('emit state', () async {
      final controller = StreamController<IsolateEvent>();
      await initializeManager(eventsStream: controller.stream);

      final simpleCubit = await createBloc(
        create: () => SimpleCubit(),
        controller: controller,
      );

      simpleCubit.add('');
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() =>
              isolateMessenger.send(const IsolateBlocTransitionEvent('id', 1)))
          .called(1);
    });

    test('receive event', () async {
      final controller = StreamController<IsolateEvent>();
      await initializeManager(eventsStream: controller.stream);

      final simpleCubit = await createBloc(
        create: () => SimpleCubit(),
        controller: controller,
      );

      controller.add(const IsolateBlocTransitionEvent('id', ''));
      await Future.delayed(const Duration(milliseconds: 1));

      // State updated when event is received
      expect(simpleCubit.state, 1);
    });

    test('emit unsent states', () async {
      final controller = StreamController<IsolateEvent>();
      await initializeManager(eventsStream: controller.stream);

      late CounterBloc bloc;
      isolateManager.registerBloc<CounterBloc, int>(() => bloc = CounterBloc());

      bloc.add(CounterEvent.increment);
      bloc.add(CounterEvent.increment);

      // state didn't changed because bloc didn't connected
      expect(bloc.state, 0);

      expect(bloc.stream, emitsInOrder([1, 2]));

      controller.add(const CreateIsolateBlocEvent(CounterBloc, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      expect(bloc.state, 2);
    });

    test('close bloc', () async {
      final controller = StreamController<IsolateEvent>();
      await initializeManager(eventsStream: controller.stream);

      final simpleCubit = await createBloc(
        create: () => SimpleCubit(),
        controller: controller,
      );

      controller.add(const CloseIsolateBlocEvent('id'));
      await Future.delayed(const Duration(milliseconds: 1));

      expect(simpleCubit.isClosed, isTrue);
    });
  });

  group('Test getBlocWrapper method', () {
    test(
      'get bloc wrapper for registered, unregistered '
      'and registered with initial state bloc',
      () async {
        final controller = StreamController<IsolateEvent>();
        var cubitsCreated = 0;
        var blocsCreated = 0;
        SimpleCubit? cubit;
        CounterBloc? bloc;

        userInitializer = () {
          var cubitWrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
          expect(cubitWrapper, isNotNull);
          // Bloc wrapper of unregistered bloc has no state
          expect(cubitWrapper.state, isNull);

          isolateManager.registerBloc<SimpleCubit, int>(() {
            cubitsCreated++;

            return cubit = SimpleCubit();
          });
          // Bloc created because no initial state is provided
          expect(cubit, isNotNull);
          cubitWrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
          expect(cubitWrapper, isNotNull);
          // Bloc wrapper of registered bloc has a state
          expect(cubitWrapper.state, 0);
          expect(cubit!.id, isNull);
          expect(cubitsCreated, 1);

          // test wit initial state
          isolateManager.registerBloc<CounterBloc, int>(
            () {
              blocsCreated++;

              return bloc = CounterBloc();
            },
            initialState: 0,
          );
          expect(bloc, isNull);

          var blocWrapper = isolateManager.getBlocWrapper<CounterBloc, int>();
          expect(blocWrapper, isNotNull);
          expect(blocWrapper.state, 0);
          // Bloc will be created only after initialization
          expect(bloc, isNull);
          expect(blocsCreated, 0);
        };

        await initializeManager(eventsStream: controller.stream);

        await Future.delayed(const Duration(milliseconds: 1));
        expect(blocsCreated, 1);

        // This calls won't create new blocs because they were already created by getBlocWrapper
        controller.add(const CreateIsolateBlocEvent(SimpleCubit, 'c'));
        controller.add(const CreateIsolateBlocEvent(CounterBloc, 'b'));
        await Future.delayed(const Duration(milliseconds: 1));

        // No new bloc created
        expect(blocsCreated, 1);
        expect(cubitsCreated, 1);

        expect(bloc!.id, 'b');
        expect(cubit!.id, 'c');
      },
    );

    group('Test IsolateBlocWrapper provided by getBlocWrapper', () {
      test('do not send event when IsolateBlocBase is not created', () async {
        await initializeManager();
        register<SimpleCubit, int>(create: () => SimpleCubit());

        final wrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
        wrapper.add('test');

        await Future.delayed(const Duration(milliseconds: 1));
        verifyNever(
            () => isolateMessenger.send(MockIsolateBlocTransitionEvent()));
      });

      test('send event when IsolateBlocBase is created and receive state',
          () async {
        final streamController = StreamController<IsolateEvent>();
        await initializeManager(eventsStream: streamController.stream);
        register<SimpleCubit, int>(create: () => SimpleCubit());

        final wrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
        streamController.add(const CreateIsolateBlocEvent(SimpleCubit, ''));
        await Future.delayed(const Duration(milliseconds: 1));
        wrapper.add('test');
        await Future.delayed(const Duration(milliseconds: 1));

        expect(wrapper.state, 1);
      });

      test('send unsent events and receive state', () async {
        final streamController = StreamController<IsolateEvent>();
        await initializeManager(eventsStream: streamController.stream);
        register<SimpleCubit, int>(create: () => SimpleCubit());

        final wrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
        wrapper.add('test');
        streamController.add(const CreateIsolateBlocEvent(SimpleCubit, ''));
        await Future.delayed(const Duration(milliseconds: 1));

        expect(wrapper.state, 1);
      });

      test('close IsolateBlocWrapper do not closes IsolateBlocBase', () async {
        await initializeManager();
        late SimpleCubit cubit;
        register<SimpleCubit, int>(create: () => cubit = SimpleCubit());

        final wrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
        await wrapper.close();

        expect(cubit.isClosed, isFalse);
      });

      test('receive state from IsolateBlocBase only when it is created',
          () async {
        final streamController = StreamController<IsolateEvent>();
        await initializeManager(eventsStream: streamController.stream);

        register<SimpleCubit, int>(create: () => SimpleCubit());

        final wrapper = isolateManager.getBlocWrapper<SimpleCubit, int>();
        streamController.add(const CreateIsolateBlocEvent(SimpleCubit, ''));
        streamController.add(const IsolateBlocTransitionEvent('', ''));
        await Future.delayed(const Duration(milliseconds: 1));

        expect(wrapper.state, 1);
      });
    });
  });
}
