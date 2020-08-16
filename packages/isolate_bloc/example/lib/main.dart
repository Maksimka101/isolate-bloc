import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

Future<void> main(List<String> arguments) async {
  await initialize(isolatedFunc);
  runApp(
    MaterialApp(
      home: IsolateBlocProvider<CounterBloc, int>(
        child: CounterScreen(),
      ),
    ),
  );
}

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: IsolateBlocListener<CounterBloc, int>(
          listener: (context, state) => print('New bloc state: $state'),
          child: IsolateBlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              return Text('You tapped $state times');
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'Increment',
            onPressed: () => context
                .isolateBloc<CounterBloc, int>()
                .add(CountEvent.increment),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'Decrement',
            onPressed: () => context
                .isolateBloc<CounterBloc, int>()
                .add(CountEvent.decrement),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

Future<void> isolatedFunc() async {
  IsolateBloc.observer = SimpleBlocObserver();
  register(create: () => CounterBloc());
}

class CounterBloc extends IsolateBloc<CountEvent, int> {
  CounterBloc() : super(0);

  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state + 1 : state - 1);
  }
}

enum CountEvent {
  increment,
  decrement,
}

class SimpleBlocObserver extends IsolateBlocObserver {
  @override
  void onEvent(IsolateBloc bloc, Object event) {
    print('New $event for $bloc');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(IsolateBloc bloc, Transition transition) {
    print('New ${transition.nextState} from $bloc');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(IsolateBloc bloc, Object error, StackTrace stackTrace) {
    print('$error in $bloc');
    super.onError(bloc, error, stackTrace);
  }
}
