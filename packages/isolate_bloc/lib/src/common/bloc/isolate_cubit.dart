import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';

/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
///
/// [IsolateBlocWrapper]<[Event]>, [State]> will receive this bloc's state.
/// This bloc must be created from UI with `createBloc<BlocT, BlocTState>`
/// function or `IsolateBlocProvider<BlocT, BlocTState>()`.
/// You can get it inside another [IsolateCubit] using `getBloc<BlocT>()`.
abstract class IsolateCubit<Event, State> extends IsolateBlocBase<Event, State> {
  /// Basic constructor. Gains initial state and generates bloc's id;
  IsolateCubit(State state) : super(state);
}
