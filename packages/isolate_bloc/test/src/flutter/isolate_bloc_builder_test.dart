import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/api_wrappers.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_cubit.dart';
import 'package:isolate_bloc/src/common/isolated_api_wrappers.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_builder.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_provider.dart';

import '../../blocs/counter_bloc.dart';
import '../../test_utils/initialize.dart';

class MyThemeApp extends StatefulWidget {
  MyThemeApp({
    Key? key,
    required IsolateBlocWrapper<ThemeInfo> themeCubit,
    required Function onBuild,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild,
        super(key: key);

  final IsolateBlocWrapper<ThemeInfo> _themeCubit;
  final Function _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState(
        themeCubit: _themeCubit,
        onBuild: _onBuild,
      );
}

class MyThemeAppState extends State<MyThemeApp> {
  MyThemeAppState({
    required IsolateBlocWrapper<ThemeInfo> themeCubit,
    required Function onBuild,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild;

  IsolateBlocWrapper<ThemeInfo> _themeCubit;
  final Function _onBuild;

  @override
  Widget build(BuildContext context) {
    return IsolateBlocBuilder<IsolateCubit<ThemeInfo, ThemeInfo>, ThemeInfo>(
      bloc: _themeCubit,
      builder: (context, theme) {
        _onBuild();

        return MaterialApp(
          key: const Key('material_app'),
          theme: theme.theme,
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('raised_button_1'),
                child: const SizedBox(),
                onPressed: () {
                  setState(
                    () => _themeCubit = createBloc<DarkThemeCubit, ThemeInfo>(),
                  );
                },
              ),
              ElevatedButton(
                key: const Key('raised_button_2'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _themeCubit = _themeCubit);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeCubit extends IsolateCubit<ThemeInfo, ThemeInfo> {
  ThemeCubit() : super(ThemeInfo.lightTheme);

  @override
  void onEventReceived(ThemeInfo event) {
    emit(event);
  }
}

enum ThemeInfo { lightTheme, darkTheme }

extension on ThemeInfo {
  ThemeData get theme => this == ThemeInfo.lightTheme ? ThemeData.light() : ThemeData.dark();
}

class DarkThemeCubit extends IsolateCubit<ThemeInfo, ThemeInfo> {
  DarkThemeCubit() : super(ThemeInfo.darkTheme);

  @override
  void onEventReceived(event) {
    emit(event);
  }
}

class MyCounterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  late IsolateBlocWrapper<int> _cubit;

  @override
  void initState() {
    _cubit = createBloc<CounterBloc, int>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key('myCounterApp'),
        body: Column(
          children: <Widget>[
            IsolateBlocBuilder<CounterBloc, int>(
              bloc: _cubit,
              buildWhen: (previousState, state) {
                return (previousState + state) % 3 == 0;
              },
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppTextCondition'),
                );
              },
            ),
            IsolateBlocBuilder<CounterBloc, int>(
              bloc: _cubit,
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppText'),
                );
              },
            ),
            ElevatedButton(
              key: const Key('myCounterAppIncrementButton'),
              child: const SizedBox(),
              onPressed: () => _cubit.add(CounterEvent.increment),
            )
          ],
        ),
      ),
    );
  }
}

void _initializer() {
  register<ThemeCubit, ThemeInfo>(create: () => ThemeCubit());
  register<DarkThemeCubit, ThemeInfo>(create: () => DarkThemeCubit());
  register<CounterBloc, int>(create: () => CounterBloc());
}

void main() {
  setUp(() async {
    testInitializePlatform(TestInitializePlatform.web);
    await testInitialize(_initializer);
  });

  group('IsolateBlocBuilder', () {
    testWidgets('passes initial state to widget', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.lightTheme.theme);
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      themeCubit.add(ThemeInfo.darkTheme);
      await tester.runAsync(() => themeCubit.stream.first);

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 2);
    });

    testWidgets('infers the cubit from the context if the cubit is not provided', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        IsolateBlocProvider<ThemeCubit, ThemeInfo>.value(
          value: themeCubit,
          child: IsolateBlocBuilder<ThemeCubit, ThemeInfo>(
            builder: (context, theme) {
              numBuilds++;

              return MaterialApp(
                key: const Key('material_app'),
                theme: theme.theme,
                home: const SizedBox(),
              );
            },
          ),
        ),
      );

      themeCubit.add(ThemeInfo.darkTheme);
      await tester.runAsync(() => themeCubit.stream.first);

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 2);

      themeCubit.add(ThemeInfo.lightTheme);
      await tester.runAsync(() => themeCubit.stream.first);

      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.lightTheme.theme);
      expect(numBuilds, 3);
    });

    testWidgets('updates cubit and performs new lookup when widget is updated', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => IsolateBlocProvider<ThemeCubit, ThemeInfo>.value(
            value: themeCubit,
            child: IsolateBlocBuilder<ThemeCubit, ThemeInfo>(
              builder: (context, theme) {
                numBuilds++;

                return MaterialApp(
                  key: const Key('material_app'),
                  theme: theme.theme,
                  home: ElevatedButton(
                    child: const SizedBox(),
                    onPressed: () => setState(() {}),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.lightTheme.theme);
      expect(numBuilds, 2);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit and '
        'unsubscribes from old cubit', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.lightTheme.theme);
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_1')));
      // await tester.runAsync(() => themeCubit.stream.first);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 2);

      themeCubit.add(ThemeInfo.lightTheme);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      final themeCubit = createBloc<DarkThemeCubit, ThemeInfo>();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_2')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 2);

      themeCubit.add(ThemeInfo.lightTheme);
      await tester.runAsync(() => themeCubit.stream.first);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.lightTheme.theme);
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final themeCubit = createBloc<ThemeCubit, ThemeInfo>()..add(ThemeInfo.darkTheme);
      await tester.runAsync(() => themeCubit.stream.first);
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeInfo.darkTheme.theme);
      expect(numBuilds, 1);
    });

    testWidgets('with buildWhen only rebuilds when buildWhen evaluates to true', (tester) async {
      await tester.pumpWidget(MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder = find.byKey(const Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final counterText1 = tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText1.data, '0');

      final conditionalCounterText1 = tester.widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 1)));
      await tester.pumpAndSettle();

      final counterText2 = tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText2.data, '1');

      final conditionalCounterText2 = tester.widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 1)));
      await tester.pumpAndSettle();

      final counterText3 = tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText3.data, '2');

      final conditionalCounterText3 = tester.widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 1)));
      await tester.pumpAndSettle();

      final counterText4 = tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText4.data, '3');

      final conditionalCounterText4 = tester.widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText4.data, '2');
    });

    testWidgets('calls buildWhen and builder with correct state', (tester) async {
      final buildWhenPreviousState = <int>[];
      final buildWhenCurrentState = <int>[];
      final states = <int>[];
      final counterCubit = createBloc<CounterBloc, int>();
      await tester.pumpWidget(
        IsolateBlocBuilder<CounterBloc, int>(
          bloc: counterCubit,
          buildWhen: (previous, state) {
            if (state % 2 == 0) {
              buildWhenPreviousState.add(previous);
              buildWhenCurrentState.add(state);

              return true;
            }

            return false;
          },
          builder: (_, state) {
            states.add(state);

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

      expect(states, [0, 2]);
      expect(buildWhenPreviousState, [1]);
      expect(buildWhenCurrentState, [2]);
    });

    testWidgets(
        'does not rebuild with latest state when '
        'buildWhen is false and widget is updated', (tester) async {
      const key = Key('__target__');
      final states = <int>[];
      final counterCubit = createBloc<CounterBloc, int>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) => IsolateBlocBuilder<CounterBloc, int>(
              bloc: counterCubit,
              buildWhen: (previous, state) => state % 2 == 0,
              builder: (_, state) {
                states.add(state);

                return ElevatedButton(
                  key: key,
                  child: const SizedBox(),
                  onPressed: () => setState(() {}),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      counterCubit
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);
      await tester.runAsync(() => counterCubit.stream.take(3).last);
      await tester.pumpAndSettle();
      expect(states, [0, 2]);

      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
      expect(states, [0, 2, 2]);
    });
  });
}
