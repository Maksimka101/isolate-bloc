import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Registers [IsolateBlocBase].
///
/// If [initialState] is not provided bloc will be created immediately.
/// So if you don't want to create bloc while initialization please provide [initialState]!
///
/// You can create [IsolateBlocBase] and get [IsolateBlocWrapper] using
/// [_createBloc] only if you have registered this [IsolateBlocBase].
///
/// Throws [IsolateManagerUnInitialized] if [IsolatedBlocManager] is null
void register<T extends IsolateBlocBase<Object?, S>, S>({
  required IsolateBlocCreator<Object?, S> create,
  S? initialState,
}) {
  final isolateManager = IsolateManager.instance;
  if (isolateManager == null) {
    throw IsolateManagerUnInitialized();
  } else {
    isolateManager.register<T, S>(create, initialState);
  }
}

/// Use this function to get [IsolateBlocBase] in [Isolate].
///
/// To get bloc in UI Isolate use IsolateBlocProvider which returns [IsolateBlocWrapper].
/// This function works this way: firstly it is wait for user's [Initializer] function
/// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
/// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
/// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
/// return free bloc from pull.
///
/// Throws [IsolateManagerUnInitialized] if [IsolatedBlocManager] is null
IsolateBlocWrapper<State> getBloc<Bloc extends IsolateBlocBase<Object, State>, State>() {
  final isolateManager = IsolateManager.instance;
  if (isolateManager == null) {
    throw IsolateManagerUnInitialized();
  } else {
    return isolateManager.getBlocWrapper<Bloc, State>();
  }
}

class IsolateManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$IsolateManager must not be null. '
        'Maybe you are calling this function in UI Isolate however '
        'it is possible only in $Initializer function context';
  }
}
