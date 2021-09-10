import 'package:isolate_bloc/isolate_bloc.dart';

class CounterBloc extends IsolateBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) {
    return Stream.value(
      event == CounterEvent.increment ? state + 1 : state - 1,
    );
  }
}

enum CounterEvent { increment, decrement }
