import 'package:isolate_bloc/isolate_bloc.dart';

class AbsentIsolateWrapper extends IIsolateWrapper {
  @override
  void kill() {}
}
