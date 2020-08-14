import 'package:isolate_bloc/isolate_bloc.dart';

import 'blocs/simple_bloc.dart';

class Initializers {
  static void empty() {}

  static void simpleBloc() {
    register(create: () => SimpleBloc());
  }
}
