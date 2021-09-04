import 'package:isolate_bloc/isolate_bloc.dart';

import '../isolate_blocs/simple_cubit.dart';

void simpleBlocInitializer() {
  register<SimpleCubit, String>(create: () => SimpleCubit());
}
