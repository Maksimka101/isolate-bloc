import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

Future<void> main(List<String> arguments) async {
  await initialize(isolatedFunc);
  runApp(
    MaterialApp(
      home: IsolateBlocProvider<CounterCubit, int>(
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
        child: IsolateBlocListener<CounterCubit, int>(
          listener: (context, state) => print('New bloc state: $state'),
          child: IsolateBlocBuilder<CounterCubit, int>(
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
            onPressed: () => context.isolateBloc<CounterCubit, int>().add(CountEvent.increment),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'Decrement',
            onPressed: () => context.isolateBloc<CounterCubit, int>().add(CountEvent.decrement),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

Future<void> isolatedFunc() async {
  IsolateBloc.observer = SimpleBlocObserver();
  register<CounterCubit, int>(create: () => CounterCubit());
}

class CounterCubit extends IsolateCubit<CountEvent, int> {
  CounterCubit() : super(0);

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
  void onClose(IsolateBlocBase bloc) {
    print('New instance of ${bloc.runtimeType}');
    super.onClose(bloc);
  }
  
  @override
  void onEvent(IsolateBlocBase bloc, Object? event) {
    print('New $event for $bloc');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(IsolateBloc bloc, Transition transition) {
    print('New ${transition.nextState} from $bloc');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(IsolateBlocBase bloc, Object error, StackTrace stackTrace) {
    print('$error in $bloc');
    super.onError(bloc, error, stackTrace);
  }
}
