import 'package:isolate_bloc/isolate_bloc.dart';

import 'blocs/counter_blocs.dart';

class Initializers {
  static void counterTest() {
    register(create: () => CounterBloc());
  }

  static void injectionTest() {
    register(create: () => CounterBloc());
    register(create: () => CounterHistoryWrapperInjector(getBloc));
  }

  static void implicitBlocCreationTest() {
    register(create: () => CounterBloc());
    register(create: () => CounterIncrementerBloc(getBloc));
  }
}
