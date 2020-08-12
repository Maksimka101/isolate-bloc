import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleBlocObserver extends IsolateBlocObserver {
  @override
  void onEvent(IsolateBloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('onEvent $event');
  }

  @override
  onTransition(IsolateBloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition $transition');
  }

  @override
  void onError(IsolateBloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('onError $error');
  }
}
