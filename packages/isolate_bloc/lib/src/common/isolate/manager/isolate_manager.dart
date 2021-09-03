import 'dart:async';
import 'dart:developer';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/isolated_platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

/// Signature for function which creates [IsolateCubit].
typedef IsolateBlocCreator = IsolateBlocBase Function();

/// Manager which works in Isolate
class IsolateManager {
  IsolateManager._internal(this._messenger, this._userInitializer);

  factory IsolateManager({
    required IsolateMessenger messenger,
    required Initializer userInitializer,
  }) {
    return instance = IsolateManager._internal(messenger, userInitializer);
  }

  static IsolateManager? instance;

  final IsolateMessenger _messenger;
  final Initializer _userInitializer;

  final InitialStates _initialStates = {};
  final _createdBlocs = <String, IsolateBlocBase>{};
  final _freeBlocs = <Type, IsolateBlocBase>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _createdBlocsSubscriptions = <String, StreamSubscription>{};

  final _initializeCompleter = Completer();
  StreamSubscription<IsolateBlocEvent>? _serviceEventsSubscription;

  /// Finish initialization and send initial states to the [BlocManager].
  Future<void> initialize() async {
    _serviceEventsSubscription = _messenger.messagesStream
        .where((event) => event is IsolateBlocEvent)
        .cast<IsolateBlocEvent>()
        .listen(_listenForMessagesFormUi);

    try {
      await _userInitializer();
    } catch (e, stacktrace) {
      log('''Error in user's Initializer function.
Error message: ${e.toString()}
Stacktrace: $stacktrace''');
    }

    _initializeCompleter.complete();
    _messenger.send(IsolateBlocsInitialized(_initialStates));
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

  /// Use this function to get [IsolateCubit] in [Isolate].
  ///
  /// To get bloc in UI [Isolate] use [IsolateBlocProvider] which returns [IsolateBlocWrapper].
  /// This function works this way: firstly it is wait for user's [Initializer] function
  /// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
  /// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
  /// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
  /// return free bloc from pull.
  IsolateBlocWrapper<State> getBlocWrapper<Bloc extends IsolateBlocBase<Object?, State>, State>() {
    late IsolateBlocWrapper<State> wrapper;
    Bloc? isolateBloc;
    _getBloc<Bloc>().then((bloc) {
      isolateBloc = bloc;

      // ignore: invalid_use_of_protected_member
      _createdBlocsSubscriptions[bloc.id] = bloc.stream.listen(wrapper.stateReceiver);
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

  void _listenForMessagesFormUi(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocTransitionEvent:
        event = event as IsolateBlocTransitionEvent;
        _receiveBlocEvent(event.blocUuid, event.event);
        break;
      case CreateIsolateBlocEvent:
        event = event as CreateIsolateBlocEvent;
        _createBloc(event.blocType);
        break;
      case CloseIsolateBlocEvent:
        event = event as CloseIsolateBlocEvent;
        _closeBloc(event.blocUuid);
        break;
      case PlatformChannelResponseEvent:
        event = event as PlatformChannelResponseEvent;
        final middleware = IsolatedPlatformChannelMiddleware.instance;
        if (middleware == null) {
          throw MethodChannelUninitializedException();
        } else {
          middleware.platformChannelResponse(event.id, event.data);
        }
        break;
      case InvokeMethodChannelEvent:
        event = event as InvokeMethodChannelEvent;
        final middleware = IsolatedPlatformChannelMiddleware.instance;
        if (middleware == null) {
          throw MethodChannelUninitializedException();
        } else {
          middleware.handlePlatformMessage(
            event.channel,
            event.id,
            event.data,
          );
        }
        break;
    }
  }

  /// Receive bloc's [uuid] and [event].
  /// Find [IsolateBlocBase] by id and add [event] to it.
  void _receiveBlocEvent(String uuid, Object? event) {
    final bloc = _createdBlocs[uuid];
    if (bloc == null) {
      throw Exception("Failed to receive event. Bloc doesn't exist");
    } else {
      bloc.add(event);
    }
  }

  /// Creates [IsolateBlocBase] and connect it to the [IsolateBlocWrapper].
  void _createBloc(Type blocType) {
    final bloc = _getFreeBlocByType(blocType);
    if (bloc != null) {
      _createdBlocsSubscriptions[bloc.id] = bloc.stream.listen(
        (state) => _messenger.send(
          IsolateBlocTransitionEvent(bloc.id, state),
        ),
      );

      _messenger.send(IsolateBlocCreatedEvent(bloc.runtimeType, bloc.id));
    }
  }

  /// Get bloc by [uuid] and close it and it's resources
  void _closeBloc(String uuid) {
    final bloc = _createdBlocs.remove(uuid);
    if (bloc == null) {
      throw Exception("Failed to close bloc because it wasn't created yet.");
    } else {
      _createdBlocsSubscriptions[uuid]?.cancel();
      bloc.close();
    }
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

  Future<void> dispose() async {
    await _serviceEventsSubscription?.cancel();
  }
}
