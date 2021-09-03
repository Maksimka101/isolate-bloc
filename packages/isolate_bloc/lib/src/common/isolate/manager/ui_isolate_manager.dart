import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = Function();

typedef IsolateManagerCreator = Future<IsolateCreateResult> Function(
  IsolateRun,
  Initializer,
  List<String> channels,
);

typedef InitialStates = Map<Type, Object?>;

class MethodChannelUninitializedException implements Exception {
  @override
  String toString() {
    return 'Method channel middleware is null. Maybe you forgot to call `await initialize(...)`?';
  }
}

/// Manager which works in UI Isolate
class UIIsolateManager {
  UIIsolateManager._internal(this._isolate, this._isolateMessenger);

  factory UIIsolateManager(IsolateCreateResult createResult) {
    return instance = UIIsolateManager._internal(createResult.isolate, createResult.messenger);
  }

  static UIIsolateManager? instance;

  final IsolateWrapper _isolate;
  final IsolateMessenger _isolateMessenger;

  InitialStates _initialStates = {};

  final _freeWrappers = <Type, List<IsolateBlocWrapper>>{};

  /// Map of [IsolateBlocWrapper] to it's id
  final _wrappers = <String, IsolateBlocWrapper>{};
  StreamSubscription<IsolateBlocEvent>? _serviceEventsSubscription;

  final _initializeCompleter = Completer<InitialStates>();

  /// Starts listening for [_isolateMessenger] and waits for [InitialStates]
  Future<void> initialize() async {
    _serviceEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is IsolateBlocEvent)
        .cast<IsolateBlocEvent>()
        .listen(_listenForIsolateEvents);

    _initialStates = await _initializeCompleter.future;
  }

  /// Start creating [IsolateBlocBase] and return [IsolateBlocWrapper].
  IsolateBlocWrapper<State> createBloc<T extends IsolateBlocBase, State>() {
    void onBlocClose(String? uuid) {
      if (uuid != null) {
        _isolateMessenger.send(CloseIsolateBlocEvent(uuid));
      }
    }

    final initialState = _initialStates[T];

    final blocWrapper = IsolateBlocWrapper<State>(
      state: initialState as State,
      eventReceiver: _isolateMessenger.send,
      onBlocClose: onBlocClose,
    );

    _freeWrappers[T] ??= [];
    _freeWrappers[T]!.add(blocWrapper);
    _isolateMessenger.send(CreateIsolateBlocEvent(T));

    return blocWrapper;
  }

  void _listenForIsolateEvents(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocsInitialized:
        _initializeCompleter.complete((event as IsolateBlocsInitialized).initialStates);
        break;
      case IsolateBlocCreatedEvent:
        event = event as IsolateBlocCreatedEvent;
        _bindFreeWrapper(event.blocType, event.blocUuid);
        break;
      case IsolateBlocTransitionEvent:
        event = event as IsolateBlocTransitionEvent;
        _receiveBlocState(event.blocUuid, event.event);
        break;
      case InvokePlatformChannelEvent:
        final methodChannelMiddleware = MethodChannelMiddleware.instance;
        if (methodChannelMiddleware == null) {
          throw MethodChannelUninitializedException();
        } else {
          event = event as InvokePlatformChannelEvent;
          methodChannelMiddleware.send(event.channel, event.data, event.id);
        }
        break;
      case MethodChannelResponseEvent:
        final methodChannelMiddleware = MethodChannelMiddleware.instance;
        if (methodChannelMiddleware == null) {
          throw MethodChannelUninitializedException();
        } else {
          event = event as MethodChannelResponseEvent;
          methodChannelMiddleware.methodChannelResponse(event.id, event.data);
        }
        break;
      default:
        throw Exception('This is internal error. If you face it please create issue\n'
            'Unknown `ServiceEvent` with type ${event.runtimeType}');
    }
  }

  /// Finish [IsolateBlocBase] creating which started by call [createBloc].
  /// Connect [IsolateBlocBase] to it's [IsolateBlocWrapper].
  void _bindFreeWrapper(Type blocType, String id) {
    if (_freeWrappers.containsKey(blocType) && _freeWrappers[blocType]!.isNotEmpty) {
      // ignore: invalid_use_of_protected_member
      _wrappers[id] = _freeWrappers[blocType]!.removeAt(0)..connectToBloc(id);
    } else {
      throw Exception('No free bloc wrapper for $blocType');
    }
  }

  /// Call when new state from [IsolateBlocBase] received.
  /// Find wrapper by bloc id and add new state to it.
  void _receiveBlocState(String blocId, Object? state) {
    // ignore: invalid_use_of_protected_member
    _wrappers[blocId]?.stateReceiver(state);
  }

  /// Free all resources and kill [Isolate] with [IsolateBlocBase]s.
  Future<void> dispose() async {
    _isolate.kill();
    await _serviceEventsSubscription?.cancel();
  }
}
