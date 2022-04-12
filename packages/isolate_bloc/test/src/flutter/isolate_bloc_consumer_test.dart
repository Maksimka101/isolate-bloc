import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

import '../../blocs/counter_bloc.dart';
import '../../test_utils/initialize.dart';

void _initializer() {
  register<CounterBloc, int>(create: CounterBloc.new);
}

void main() {
  setUp(() async {
    testInitializePlatform(TestInitializePlatform.web);
    await testInitialize(_initializer);
  });

  group('IsolateBlocConsumer', () {
    testWidgets(
        'accesses the bloc directly and passes initial state to builder and '
        'nothing to listener', (tester) async {
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocProvider<CounterBloc, int>(
              child: IsolateBlocConsumer<CounterBloc, int>(
                builder: (context, state) {
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the bloc directly '
        'and passes multiple states to builder and listener', (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocConsumer<CounterBloc, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );

      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets(
        'accesses the bloc via context and passes initial state to builder',
        (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        IsolateBlocProvider<CounterBloc, int>.value(
          value: counterCubit,
          child: MaterialApp(
            home: Scaffold(
              body: IsolateBlocConsumer<CounterBloc, int>(
                bloc: counterCubit,
                builder: (context, state) {
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the bloc via context and passes multiple states to builder',
        (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocConsumer<CounterBloc, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger rebuilds when buildWhen evaluates to false',
        (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocConsumer<CounterBloc, int>(
              bloc: counterCubit,
              buildWhen: (previous, current) => (previous + current) % 3 == 0,
              builder: (context, state) {
                builderStates.add(state);

                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });

    testWidgets(
        'does not trigger rebuilds when '
        'buildWhen evaluates to false (inferred bloc)', (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocProvider<CounterBloc, int>.value(
              value: counterCubit,
              child: IsolateBlocConsumer<CounterBloc, int>(
                buildWhen: (previous, current) => (previous + current) % 3 == 0,
                builder: (context, state) {
                  builderStates.add(state);

                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });

    testWidgets('updates when cubit/bloc reference has changed',
        (tester) async {
      const buttonKey = Key('__button__');
      var counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IsolateBlocConsumer<CounterBloc, int>(
                  bloc: counterCubit,
                  builder: (context, state) {
                    builderStates.add(state);

                    return TextButton(
                      key: buttonKey,
                      onPressed: () => setState(() {}),
                      child: Text('State: $state'),
                    );
                  },
                  listener: (_, state) {
                    listenerStates.add(state);
                  },
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(builderStates, [0, 1]);
      expect(listenerStates, [1]);

      counterCubit = createBloc<CounterBloc, int>();
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0, 1, 0]);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger listen when listenWhen evaluates to false',
        (tester) async {
      final counterCubit = createBloc<CounterBloc, int>();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsolateBlocConsumer<CounterBloc, int>(
              bloc: counterCubit,
              builder: (context, state) {
                builderStates.add(state);

                return Text('State: $state');
              },
              listenWhen: (previous, current) => (previous + current) % 3 == 0,
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(builderStates, [0, 1]);
      expect(listenerStates, isEmpty);

      counterCubit.add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.first);
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 1, 2]);
      expect(listenerStates, [2]);
    });

    testWidgets(
        'calls buildWhen/listenWhen and builder/listener with correct states',
        (tester) async {
      final buildWhenPreviousState = <int>[];
      final buildWhenCurrentState = <int>[];
      final buildStates = <int>[];
      final listenWhenPreviousState = <int>[];
      final listenWhenCurrentState = <int>[];
      final listenStates = <int>[];
      final counterCubit = createBloc<CounterBloc, int>();
      await tester.pumpWidget(
        IsolateBlocConsumer<CounterBloc, int>(
          bloc: counterCubit,
          listenWhen: (previous, current) {
            if (current % 3 == 0) {
              listenWhenPreviousState.add(previous);
              listenWhenCurrentState.add(current);

              return true;
            }

            return false;
          },
          listener: (_, state) {
            listenStates.add(state);
          },
          buildWhen: (previous, current) {
            if (current.isEven) {
              buildWhenPreviousState.add(previous);
              buildWhenCurrentState.add(current);

              return true;
            }

            return false;
          },
          builder: (_, state) {
            buildStates.add(state);

            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      counterCubit
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.take(3).last);
      await tester.pumpAndSettle();

      expect(buildStates, [0, 2]);
      expect(buildWhenPreviousState, [1]);
      expect(buildWhenCurrentState, [2]);

      expect(listenStates, [3]);
      expect(listenWhenPreviousState, [2]);
      expect(listenWhenCurrentState, [3]);
    });
  });
}
