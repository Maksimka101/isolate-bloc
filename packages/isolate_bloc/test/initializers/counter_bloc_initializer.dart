import 'package:isolate_bloc/isolate_bloc.dart';

import '../isolate_blocs/increment_cubit.dart';

void counterBlocInitializer() {
  register<CounterCubit, int>(create: () => CounterCubit());
}
