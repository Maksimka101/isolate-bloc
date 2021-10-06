import 'package:isolate_bloc/isolate_bloc.dart';

import 'blocs/simple_cubit.dart';

class Initializers {
  static void empty() {}

  static void simpleBloc() {
    register<SimpleCubit, Object>(create: () => SimpleCubit());
  }
}
