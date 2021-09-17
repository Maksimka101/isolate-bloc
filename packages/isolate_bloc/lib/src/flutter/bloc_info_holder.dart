import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';

/// Use it to store bloc in context using provider.
class BlocInfoHolder {
  final _blocsInfo = <Type, List<IsolateBlocWrapper>>{};

  /// Return [IsolateBlocWrapper] associated with given [IsolateCubit]'s Type
  IsolateBlocWrapper<State>? getWrapperByType<T extends IsolateBlocBase<Object?, State>, State>() {
    return _blocsInfo[T]?.last as IsolateBlocWrapper<State>?;
  }

  /// Add [IsolateBlocWrapper] associated with [IsolateCubit] type.
  void addBlocInfo<T extends IsolateBlocBase>(IsolateBlocWrapper wrapper) {
    _blocsInfo[T] ??= [];
    _blocsInfo[T]!.add(wrapper);
  }

  /// Remove [IsolateBlocWrapper] associated with [IsolateCubit]
  IsolateBlocWrapper? removeBloc<T extends IsolateBlocBase>() {
    return _blocsInfo[T]?.removeLast();
  }
}
