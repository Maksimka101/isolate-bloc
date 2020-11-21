import 'package:isolate_bloc/isolate_bloc.dart';

/// Simple counter bloc. Increment state on `true` event and decrement on `false`
class CounterBloc extends IsolateBloc<bool, int> {
  CounterBloc() : super(0);

  @override
  void onEventReceived(bool event) {
    emit(state + (event ? 1 : -1));
  }
}
