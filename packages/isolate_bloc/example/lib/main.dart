import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/change.dart';

Future<void> main(List<String> arguments) async {
  await initialize(isolatedFunc);
  runApp(
    MaterialApp(
      home: IsolateBlocProvider<CounterCubit, int>(
        child: const CounterScreen(),
      ),
    ),
  );
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({Key? key}) : super(key: key);

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
    log('New instance of ${bloc.runtimeType}');
    super.onClose(bloc);
  }

  @override
  void onEvent(IsolateBlocBase bloc, Object? event) {
    log('New $event for $bloc');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(IsolateBloc bloc, Transition transition) {
    log('New ${transition.nextState} from $bloc');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(IsolateBlocBase bloc, Object error, StackTrace stackTrace) {
    log('$error in $bloc');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(IsolateBlocBase bloc, Change change) {
    log('$change in $bloc');
    super.onChange(bloc, change);
  }

  @override
  void onCreate(IsolateBlocBase bloc) {
    log('onCreate in $bloc');
    super.onCreate(bloc);
  }
}
