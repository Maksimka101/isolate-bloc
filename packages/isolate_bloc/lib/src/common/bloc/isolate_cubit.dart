import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';

/// {@template isolate_cubit_description}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
///
/// It must be created:
///   * from UI with [createBloc]<Bloc, State> function
///     or with `IsolateBlocProvider<Bloc, State>()` widget.
///   * from Isolate with [getBloc]<Bloc> function.
///
/// You shouldn't create in manually and use it standalone.
/// {@endtemplate}
abstract class IsolateCubit<Event, State>
    extends IsolateBlocBase<Event, State> {
  /// {@macro isolate_cubit}
  IsolateCubit(State state) : super(state);
}
