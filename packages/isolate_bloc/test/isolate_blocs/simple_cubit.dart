import 'package:isolate_bloc/isolate_bloc.dart';

/// Simple cubit which is send "empty" as initial state and "data" as any another states.
class SimpleCubit extends IsolateCubit<Object, String> {
  SimpleCubit() : super("empty");

  @override
  void onEventReceived(Object event) {
    emit("data");
  }
}
