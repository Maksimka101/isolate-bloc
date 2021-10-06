import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleBlocObserver extends IsolateBlocObserver {
  @override
  void onEvent(IsolateBlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent $event');
  }

  @override
  onTransition(IsolateBloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition $transition');
  }

  @override
  void onError(IsolateBlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('onError $error');
  }
}
