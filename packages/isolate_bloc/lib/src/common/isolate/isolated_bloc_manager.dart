import 'dart:async';

import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_connector.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

/// Signature for function which creates [IsolateCubit].
typedef IsolateBlocCreator = IsolateBlocBase Function();

/// Maintain [IsolateCubit]s in isolate
class IsolatedBlocManager {
  IsolatedBlocManager._(this._isolatedConnector);

  /// Initialize [IsolatedBlocManager]. Receive [IsolatedConnector].
  factory IsolatedBlocManager.initialize(IsolatedConnector connector) {
    return IsolatedBlocManager.instance = IsolatedBlocManager._(connector);
  }

  static IsolatedBlocManager? instance;
  final IsolatedConnector _isolatedConnector;
  final _initialStates = <Type, dynamic>{};
  final _freeBlocs = <Type, IsolateBlocBase>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _createdBlocs = <String, IsolateBlocBase>{};
  final _createdBlocsSubscriptions = <String, List<StreamSubscription>>{};
  final _initializeCompleter = Completer();

  /// Finish initialization and send initial states to the [BlocManager].
  void initializeCompleted() {
    _initializeCompleter.complete();
    _isolatedConnector.sendEvent(IsolateBlocsInitialized(_initialStates));
  }

  /// Returns new bloc from cached in [_freeBlocs] or create new one.
  IsolateBlocBase? _getFreeBlocByType(Type type) {
    IsolateBlocBase? bloc;
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

  Future<T> _getBloc<T extends IsolateBlocBase>() async {
    await _initializeCompleter.future;
    final blocsT = _createdBlocs.values.whereType<T>();
    if (blocsT.isNotEmpty) {
      return blocsT.first;
    } else if (_freeBlocs.containsKey(T)) {
      return _freeBlocs[T] as T;
    } else {
      final blocCreator = _blocCreators[T];
      if (blocCreator == null) {
        throw Exception("Failed to find BlocCreator for $T. Maybe you forget to `register` it?");
      } else {
        return _freeBlocs[T] = blocCreator() as T;
      }
    }
  }

  /// Use this function to get [IsolateCubit] in [Isolate].
  ///
  /// To get bloc in UI [Isolate] use [IsolateBlocProvider] which returns [IsolateBlocWrapper].
  /// This function works this way: firstly it is wait for user's [Initializer] function
  /// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
  /// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
  /// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
  /// return free bloc from pull.
  IsolateBlocWrapper<State> getBlocWrapper<Bloc extends IsolateBlocBase<Object?, State>, State extends Object>() {
    late IsolateBlocWrapper<State> wrapper;
    Bloc? isolateBloc;
    _getBloc<Bloc>().then((bloc) {
      isolateBloc = bloc;

      _createdBlocsSubscriptions[bloc.id] ??= [];
      // ignore: invalid_use_of_protected_member
      _createdBlocsSubscriptions[bloc.id]!.add(bloc.stream.listen(wrapper.stateReceiver));
      // ignore: invalid_use_of_protected_member
      wrapper.connectToBloc(bloc.id);
    });
    void onBLocClose(_) => isolateBloc?.close();
    void eventReceiver(IsolateBlocTransitionEvent event) {
      isolateBloc?.add(event.event);
    }

    wrapper = IsolateBlocWrapper.noInitState(eventReceiver, onBLocClose);
    return wrapper;
  }

  /// Receive bloc's [uuid] and [event].
  /// Find [IsolateCubit] by id and add [event] to it.
  void blocEventReceiver(String uuid, Object? event) {
    final bloc = _createdBlocs[uuid];
    if (bloc == null) {
      print("Failed to receive event. Bloc doesn't exist");
    } else {
      bloc.add(event);
    }
  }

  /// Create [IsolateCubit] and connect it to the [IsolateBlocWrapper].
  void createBloc(Type blocType) {
    final bloc = _getFreeBlocByType(blocType);
    if (bloc != null) {
      _createdBlocsSubscriptions[bloc.id] ??= [];
      _createdBlocsSubscriptions[bloc.id]!.add(
        bloc.stream.listen(
          (state) => _isolatedConnector.sendEvent(
            IsolateBlocTransitionEvent(bloc.id, state),
          ),
        ),
      );
      _isolatedConnector.sendEvent(IsolateBlocCreatedEvent(bloc.runtimeType, bloc.id));
    }
  }

  /// Get bloc by [uuid] and close it and it's resources
  void closeBloc(String uuid) {
    final bloc = _createdBlocs.remove(uuid);
    if (bloc == null) {
      throw Exception("Failed to close bloc because it wasn't created yet.");
    } else {
      for (final subscription in _createdBlocsSubscriptions[uuid] ?? <StreamSubscription>[]) {
        subscription.cancel();
      }
      bloc.close();
    }
  }

  /// Register [IsolateCubit].
  /// You can create [IsolateCubit] and get [IsolateBlocWrapper] from
  /// [BlocManager].createBloc only if you register this [IsolateCubit].
  void register(IsolateBlocCreator creator) {
    final bloc = creator();
    _initialStates[bloc.runtimeType] = bloc.state;
    _freeBlocs[bloc.runtimeType] = bloc;
    _blocCreators[bloc.runtimeType] = creator;
  }
}
