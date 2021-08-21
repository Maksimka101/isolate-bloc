import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_connector.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

import '../bloc/isolate_bloc.dart';

/// Signature for function which creates [IsolateBloc].
typedef IsolateBlocCreator = IsolateBloc Function();

/// Maintain [IsolateBloc]s in isolate
class IsolatedBlocManager {
  IsolatedBlocManager._(this._isolatedConnector);

  /// Initialize [IsolatedBlocManager]. Receive [IsolatedConnector].
  factory IsolatedBlocManager.initialize(IsolatedConnector connector) {
    return IsolatedBlocManager.instance = IsolatedBlocManager._(connector);
  }

  static IsolatedBlocManager? instance;
  final IsolatedConnector _isolatedConnector;
  final _initialStates = <Type, Object>{};
  final _freeBlocs = <Type, IsolateBloc>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _createdBlocs = <String, IsolateBloc>{};
  final _initializeCompleter = Completer();

  /// Finish initialization and send initial states to the [BlocManager].
  void initializeCompleted() {
    _initializeCompleter.complete();
    _isolatedConnector.sendEvent(IsolateBlocsInitialized(_initialStates));
  }

  /// Returns new bloc from cached in [_freeBlocs] or create new one.
  IsolateBloc? _getFreeBlocByType(Type type) {
    IsolateBloc? bloc;
    if (_freeBlocs.containsKey(type)) {
      bloc = _freeBlocs.remove(type)!;
    } else {
      final blocCreator = _blocCreators[type];
      if (blocCreator == null) {
        print("Can't create IsolateBloc with type $type.\n"
            "Maybe you forgot to register it?");
      } else {
        bloc = blocCreator.call();
      }
    }
    if (bloc != null) {
      _createdBlocs[bloc.id] = bloc;
      return bloc;
    } else {
      return null;
    }
  }

  Future<T?> _getBloc<T extends IsolateBloc>() async {
    await _initializeCompleter.future;
    final blocsT = _createdBlocs.values.whereType<T>();
    if (blocsT.isNotEmpty) {
      return blocsT.first;
    } else if (_freeBlocs.containsKey(T)) {
      return _freeBlocs[T] as T;
    } else {
      final blocCreator = _blocCreators[T];
      if (blocCreator == null) {
        print("Failed to find BlocCreator for $T");
        return null;
      } else {
        return _freeBlocs[T] = blocCreator() as T;
      }
    }
  }

  /// Use this function to get [IsolateBloc] in [Isolate].
  /// 
  /// To get bloc in UI [Isolate] use [IsolateBlocProvider] which returns [IsolateBlocWrapper].
  /// This function works this way: firstly it is wait for user's [Initializer] function
  /// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
  /// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
  /// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
  /// return free bloc from pull.
  IsolateBlocWrapper<State> getBlocWrapper<Bloc extends IsolateBloc<Object, State>, State extends Object>() {
    late IsolateBlocWrapper<State> wrapper;
    Bloc? isolateBloc;
    _getBloc<Bloc>().then((bloc) {
      if (bloc == null) {
        print("Failed to get bloc with type $Bloc");
      } else {
        isolateBloc = bloc;
        bloc.listen(wrapper.stateReceiver);
        wrapper.connectToBloc(bloc.id);
      }
    });
    final onBLocClose = (_) => isolateBloc?.close();
    final eventReceiver = (IsolateBlocTransitionEvent<Object> event) => isolateBloc?.add(event.event);
    wrapper = IsolateBlocWrapper.noInitState(eventReceiver, onBLocClose);
    return wrapper;
  }

  /// Receive bloc's [uuid] and [event].
  /// Find [IsolateBloc] by id and add [event] to it.
  void blocEventReceiver(String uuid, Object event) {
    final bloc = _createdBlocs[uuid];
    if (bloc == null) {
      print("Failed to receive event. Bloc doesn't exist");
    } else {
      bloc.add(event);
    }
  }

  /// Create [IsolateBloc] and connect it to the [IsolateBlocWrapper].
  void createBloc(Type blocType) {
    final bloc = _getFreeBlocByType(blocType);
    if (bloc != null) {
      bloc.listen(
        (state) => _isolatedConnector.sendEvent(
          IsolateBlocTransitionEvent(bloc.id, state),
        ),
      );
      _isolatedConnector.sendEvent(IsolateBlocCreatedEvent(bloc.runtimeType, bloc.id));
    }
  }

  /// Get bloc by [uuid] and close it.
  void closeBloc(String uuid) {
    final bloc = _createdBlocs.remove(uuid);
    if (bloc == null) {
      print("Failed to close bloc because it wasn't created yet.");
    } else {
      bloc.close();
    }
  }

  /// Register [IsolateBloc].
  /// You can create [IsolateBloc] and get [IsolateBlocWrapper] from
  /// [BlocManager].createBloc only if you register this [IsolateBloc].
  void register(IsolateBlocCreator creator) {
    final bloc = creator();
    _initialStates[bloc.runtimeType] = bloc.state;
    _freeBlocs[bloc.runtimeType] = bloc;
    _blocCreators[bloc.runtimeType] = creator;
  }
}
