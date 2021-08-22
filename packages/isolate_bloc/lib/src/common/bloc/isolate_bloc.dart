import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_observer.dart';

abstract class IsolateBloc<Event, State> extends IsolateBlocBase<Event, State> {
  IsolateBloc(State state) : super(state);

  /// The current [IsolateBlocObserver] instance.
  static IsolateBlocObserver observer = IsolateBlocObserver();
}
