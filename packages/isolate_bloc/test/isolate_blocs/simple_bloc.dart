import 'package:isolate_bloc/isolate_bloc.dart';

/// Simple bloc which is send "empty" as initial state and "data" as any another states.
class SimpleBloc extends IsolateCubit<Object, String> {
  SimpleBloc() : super("empty");

  @override
  void onEventReceived(Object event) {
    emit("data");
  }
}
