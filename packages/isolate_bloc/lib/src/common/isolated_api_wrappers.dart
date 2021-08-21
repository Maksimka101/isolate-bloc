import 'package:isolate_bloc/src/common/bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_bloc_manager.dart';

/// Registers [IsolateBloc].
///
/// You can create [IsolateBloc] and get [IsolateBlocWrapper] using
/// [createBloc] only if you have registered this [IsolateBloc].
///
/// Throws [IsolatedBlocManagerUnInitialized] if [IsolatedBlocManager] is null
void register({
  required IsolateBlocCreator create,
}) {
  final blocManager = IsolatedBlocManager.instance;
  if (blocManager == null) {
    throw IsolatedBlocManagerUnInitialized();
  } else {
    blocManager.register(create);
  }
}

/// Use this function to get [IsolateBloc] in [Isolate].
///
/// To get bloc in UI Isolate use IsolateBlocProvider which returns [IsolateBlocWrapper].
/// This function works this way: firstly it is wait for user's [Initializer] function
/// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
/// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
/// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
/// return free bloc from pull.
///
/// Throws [IsolatedBlocManagerUnInitialized] if [IsolatedBlocManager] is null
IsolateBlocWrapper<State> getBloc<Bloc extends IsolateBloc<Object, State>, State extends Object>() {
  final blocManager = IsolatedBlocManager.instance;
  if (blocManager == null) {
    throw IsolatedBlocManagerUnInitialized();
  } else {
    return blocManager.getBlocWrapper<Bloc, State>();
  }
}

class IsolatedBlocManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$IsolatedBlocManager must not be null. '
        'Maybe you are calling this function in UI Isolate however '
        'it is possible only in $Initializer function context';
  }
}
