import 'package:isolate_bloc/isolate_bloc.dart';

class CounterBloc extends IsolateBloc<CountEvent, int> {
  CounterBloc() : super(0);

  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state + 1 : state - 1);
  }
}

class CounterIncrementerBloc extends IsolateBloc<CountEvent, int> {
  CounterIncrementerBloc(this.bloc) : super(0) {
    for (var i = 0; i < _incrementCount; i++) {
      bloc.add(CountEvent.increment);
    }
    _incrementCount++;
  }

  final IsolateBlocWrapper<int> bloc;
  static int _incrementCount = 1;

  @override
  void onEventReceived(CountEvent event) {}
}

enum CountEvent {
  increment,
  decrement,
}

class CounterHistoryWrapperInjector extends IsolateBloc<int, List<int>> {
  CounterHistoryWrapperInjector(this.counterBloc) : super([]) {
    counterBloc.listen(onEventReceived);
  }

  final IsolateBlocWrapper<int> counterBloc;
  final _history = <int>[];

  @override
  void onEventReceived(int event) {
    emit(_history..add(event));
  }
}
