import 'package:isolate_bloc/isolate_bloc.dart';

/// Simple counter cubit. Increment state on `true` event and decrement on `false`
class CounterCubit extends IsolateCubit<bool, int> {
  CounterCubit() : super(0);

  @override
  void onEventReceived(bool event) {
    emit(state + (event ? 1 : -1));
  }
}
