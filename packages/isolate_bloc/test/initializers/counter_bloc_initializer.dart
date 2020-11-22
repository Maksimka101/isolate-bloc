import 'package:isolate_bloc/isolate_bloc.dart';

import '../isolate_blocs/increment_bloc.dart';

void counterBlocInitializer() {
  register(create: () => CounterBloc());
}
