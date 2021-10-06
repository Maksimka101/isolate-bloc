// ignore_for_file: prefer-match-file-name
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/manager/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// {@template register}
/// Registers [IsolateBlocBase]. This allows you to create it in UI Isolate using [createBloc] function.
///
/// This function may be called only in [Initializer] (function which is called in Isolate)
///
/// If [initialState] is not provided bloc will be created immediately.
/// So if you don't want to create bloc while initialization please provide [initialState]!
///
/// Throws [IsolateManagerUnInitialized] if [IsolatedBlocManager] is null. It may happen only if you call this function
/// from UI Isolate.
///
/// How to use:
/// ```
/// void isolatedFunc() {
///   register<CounterCubit, int>(create: () => CounterCubit());
/// }
/// ```
/// {@endtemplate}
void register<T extends IsolateBlocBase<Object?, S>, S>({
  required IsolateBlocCreator<Object?, S> create,
  S? initialState,
}) {
  final isolateManager = IsolateManager.instance;
  if (isolateManager == null) {
    throw IsolateManagerUnInitialized();
  } else {
    isolateManager.registerBloc<T, S>(create, initialState: initialState);
  }
}

/// {@template get_bloc}
/// Use this function to communicate with [IsolateBlocBase] in [Isolate].
///
/// To get bloc in UI Isolate use [IsolateBlocProvider] which returns [IsolateBlocWrapper].
///
/// This function works this way:
///   * waits for user's [Initializer] function
///   * looks for created bloc with BlocA type
///     * if it finds any, so returns this bloc's [IsolateBlocWrapper]
///     * else it creates a new bloc and adds to the pull of free blocs.
///       So when UI will call `create()`, it won't create a new bloc but return free bloc from pull.
///
/// Throws [IsolateManagerUnInitialized] if [IsolatedBlocManager] is null.
///
/// An example of how to provide Weather bloc to Theme bloc:
/// ```
/// void isolatedFunc() {
///   register<ThemeBloc, ThemeState>(
///     create: () => ThemeBloc(
///       weatherBloc: getBloc<WeatherBloc, WeatherState>(),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
IsolateBlocWrapper<S> getBloc<B extends IsolateBlocBase<Object, S>, S>() {
  final isolateManager = IsolateManager.instance;
  if (isolateManager == null) {
    throw IsolateManagerUnInitialized();
  } else {
    return isolateManager.getBlocWrapper<B, S>();
  }
}

/// This exception indicates that [IsolateManager] isn't initialized
///
/// [IsolateManager] may be uninitialized in these situations:
///   * some function is called in UI Isolate
///   * [IsolateManager.instance] manually set to `null`
class IsolateManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$IsolateManager must not be null. '
        'Maybe you are calling this function in UI Isolate however '
        'it is possible only in $Initializer function context';
  }
}
