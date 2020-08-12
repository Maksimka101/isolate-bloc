import 'package:isolate_bloc/isolate_bloc.dart';

class CounterBloc extends IsolateBloc<CountEvent, int> {
  CounterBloc() : super(0);

  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state + 1 : state - 1);
  }
}

class CounterIncrementerBloc extends IsolateBloc<CountEvent, int> {
  final BlocInjector injector;
  static int _incrementCount = 1;

  CounterIncrementerBloc(this.injector) : super(0) {
    var bloc = injector<CounterBloc, int>();
    for (var i = 0; i < _incrementCount; i++) {
      bloc.add(CountEvent.increment);
    }
    _incrementCount++;
  }

  @override
  void onEventReceived(CountEvent event) {}
}

enum CountEvent {
  increment,
  decrement,
}

class CounterHistoryWrapperInjector extends IsolateBloc<int, List<int>> {
  final BlocInjector injector;
  final _history = <int>[];

  CounterHistoryWrapperInjector(this.injector) : super([]) {
    injector<CounterBloc, int>().listen(onEventReceived);
  }

  @override
  void onEventReceived(int event) {
    emit(_history..add(event));
  }
}
