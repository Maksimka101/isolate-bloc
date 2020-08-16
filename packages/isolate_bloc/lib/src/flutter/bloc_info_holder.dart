import '../common/bloc/isolate_bloc.dart';
import '../common/bloc/isolate_bloc_wrapper.dart';

/// Use it to store bloc uuid's and type's in context using provider.
class BlocInfoHolder {
  final _blocsInfo = <Type, IsolateBlocWrapper>{};

  /// Return [IsolateBlocWrapper] associated with given [IsolateBloc]'s Type
  IsolateBlocWrapper<State>
      getWrapperByType<T extends IsolateBloc<Object, State>, State>() =>
      _blocsInfo[T] as IsolateBlocWrapper<State>;

  /// Add [IsolateBlocWrapper] associated with [IsolateBloc] type.
  void addBlocInfo<T extends IsolateBloc>(IsolateBlocWrapper wrapper) =>
      _blocsInfo[T] = wrapper;

  /// Remove [IsolateBlocWrapper] associated with [IsolateBloc]
  IsolateBlocWrapper removeBloc<T extends IsolateBloc>() =>
      _blocsInfo.remove(T);
}
