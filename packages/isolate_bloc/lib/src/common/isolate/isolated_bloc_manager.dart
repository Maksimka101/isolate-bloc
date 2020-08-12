import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_connector.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

import '../bloc/isolate_bloc.dart';

/// Signature for function which creates [IsolateBloc].
typedef IsolateBlocCreator<Event, State> = IsolateBloc<Event, State> Function();

/// Maintain [IsolateBloc]s in isolate
class IsolatedBlocManager {
  static IsolatedBlocManager instance;
  final IsolatedConnector _isolatedConnector;
  final _initialStates = <Type, Object>{};
  final _freeBlocs = <Type, IsolateBloc>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _registeredWrappers = <Type, Object>{};
  final _createdBlocs = <String, IsolateBloc>{};
  final _createdBlocsByType = <Type, IsolateBloc>{};
  final _initializeCompleter = Completer();

  /// Finish initialization and send initial states to the [BlocManager].
  void initializeCompleted() {
    _initializeCompleter.complete();
    _isolatedConnector.sendEvent(IsolateBlocsInitialized(_initialStates));
  }

  /// Initialize [IsolatedBlocManager]. Receive [IsolatedConnector].
  static IsolatedBlocManager initialize(IsolatedConnector connector) {
    return IsolatedBlocManager.instance = IsolatedBlocManager._(connector);
  }

  IsolatedBlocManager._(this._isolatedConnector);

  /// Returns new bloc from cached in [_freeBlocs] or create new one.
  IsolateBloc _getFreeBlocByType(Type type) {
    IsolateBloc bloc;
    if (_freeBlocs.containsKey(type)) {
      bloc = _freeBlocs.remove(type);
    } else {
      bloc = _blocCreators[type]();
    }
    _createdBlocs[bloc.id] = bloc;
    _createdBlocsByType[type] = bloc;
    return bloc;
  }

  Future<T> _getBloc<T extends IsolateBloc>() async {
    await _initializeCompleter.future;
    if (_createdBlocsByType.containsKey(T)) {
      return _createdBlocsByType[T];
    } else if (_freeBlocs.containsKey(T)) {
      return _freeBlocs[T];
    } else {
      return _freeBlocs[T] = _blocCreators[T]();
    }
  }

  /// Use this function to get [IsolateBloc] in [Isolate].
  /// To get bloc in UI [Isolate] use IsolateBlocProvider which returns [IsolateBlocWrapper].
  /// This function works this way: firstly it is wait for user's [Initializer] function
  /// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
  /// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
  /// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
  /// return free bloc from pull.
  IsolateBlocWrapper<State> getBlocWrapper<Bloc extends IsolateBloc, State>() {
    IsolateBlocWrapper<State> wrapper;
    Bloc isolateBloc;
    _getBloc<Bloc>().then((bloc) {
      isolateBloc = bloc;
      bloc.listen(wrapper.stateReceiver);
      wrapper.connectToBloc(bloc.id);
    });
    final onBLocClose = (_) => isolateBloc?.close();
    final eventReceiver = (Object event) => isolateBloc?.add(event);
    wrapper = IsolateBlocWrapper.noInitState(eventReceiver, onBLocClose);
    return wrapper;
  }

  /// Receive bloc's [uuid] and [event].
  /// Find [IsolateBloc] by id and add to [event] to it.
  void blocEventReceiver(String uuid, Object event) {
    _createdBlocs[uuid].add(event);
  }

  /// Create [IsolateBloc] and connect it to the [IsolateBlocWrapper].
  void createBloc(Type blocType) {
    assert(
      _blocCreators.containsKey(blocType) ||
          _registeredWrappers.containsKey(blocType),
      "You must register bloc or bloc wrapper to create it.",
    );
    if (_blocCreators.containsKey(blocType)) {
      // ignore: close_sinks
      var bloc = _getFreeBlocByType(blocType);
      bloc.listen(
        (state) => _isolatedConnector.sendEvent(
          IsolateBlocTransitionEvent(bloc.id, state),
        ),
      );
      _isolatedConnector
          .sendEvent(IsolateBlocCreatedEvent(bloc.runtimeType, bloc.id));
    } else {
      BlocManager.instance.createBloc();
    }
  }

  /// Get bloc by [uuid] and close it.
  void closeBloc(String uuid) {
    _createdBlocsByType.remove(_createdBlocs.remove(uuid)).close();
  }

// todo
// Register [IsolateBlocWrapper].
//  void registerWrapper<BlocA, BlocAState>() {
//    _registeredWrappers[BlocA] = BlocAState;
//  }

  /// Register [IsolateBloc].
  /// You can create [IsolateBloc] and get [IsolateBlocWrapper] from
  /// [BlocManager].createBloc only if you register this [IsolateBloc].
  void register<Event, State>(IsolateBlocCreator<Event, State> creator) {
    // ignore: close_sinks
    final bloc = creator();
    _initialStates[bloc.runtimeType] = bloc.state;
    _freeBlocs[bloc.runtimeType] = bloc;
    _blocCreators[bloc.runtimeType] = creator;
  }
}
