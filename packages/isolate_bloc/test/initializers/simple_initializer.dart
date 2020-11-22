import 'package:isolate_bloc/isolate_bloc.dart';

import '../isolate_blocs/simple_bloc.dart';

void simpleBlocInitializer() {
  register(create: () => SimpleBloc());
}
