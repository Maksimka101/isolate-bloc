import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';

/// Manager which works in UI Isolate
class UIIsolateManager {
  UIIsolateManager._internal(
    this._isolate,
    this._isolateMessenger,
    this._methodChannelMiddleware,
  );

  factory UIIsolateManager(
    IsolateCreateResult createResult,
    IMethodChannelMiddleware methodChannelMiddleware,
  ) {
    return instance = UIIsolateManager._internal(
      createResult.isolate,
      createResult.messenger,
      methodChannelMiddleware,
    );
  }

  static UIIsolateManager? instance;

  final IIsolateWrapper _isolate;
  final IIsolateMessenger _isolateMessenger;
  final IMethodChannelMiddleware _methodChannelMiddleware;

  InitialStates _initialStates = {};

  /// Map of [IsolateBlocWrapper] to it's id
  final _wrappers = <String, IsolateBlocWrapper>{};
  StreamSubscription<IsolateBlocEvent>? _serviceEventsSubscription;

  final _initializeCompleter = Completer<InitialStates>();

  /// Starts listening for [_isolateMessenger] and waits for [InitialStates]
  Future<void> initialize() async {
    _serviceEventsSubscription = _isolateMessenger.messagesStream.listen(_listenForIsolateEvents);

    _initialStates = await _initializeCompleter.future;
  }

  /// Start creating [IsolateBlocBase] and return [IsolateBlocWrapper].
  IsolateBlocWrapper<S> createBloc<T extends IsolateBlocBase, S>() {
    void onBlocClose(String uuid) {
      _isolateMessenger.send(CloseIsolateBlocEvent(uuid));
    }

    final initialState = _initialStates[T];

    late IsolateBlocWrapper<S> blocWrapper;
    blocWrapper = IsolateBlocWrapper<S>(
      state: initialState as S,
      eventReceiver: (event) {
        _isolateMessenger.send(
          // ignore: invalid_use_of_protected_member
          IsolateBlocTransitionEvent(blocWrapper.isolateBlocId!, event),
        );
      },
      onBlocClose: onBlocClose,
    );

    // ignore: invalid_use_of_protected_member
    final blocId = blocWrapper.isolateBlocId!;

    _wrappers[blocId] = blocWrapper;
    _isolateMessenger.send(CreateIsolateBlocEvent(T, blocId));

    return blocWrapper;
  }

  /// Free all resources and kill [Isolate] with [IsolateBlocBase]s.
  Future<void> dispose() async {
    _isolate.kill();
    await _serviceEventsSubscription?.cancel();
  }

  void _listenForIsolateEvents(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocsInitialized:
        _initializeCompleter.complete((event as IsolateBlocsInitialized).initialStates);
        break;
      case IsolateBlocCreatedEvent:
        event = event as IsolateBlocCreatedEvent;
        _onBlocCreated(event.blocId);
        break;
      case IsolateBlocTransitionEvent:
        event = event as IsolateBlocTransitionEvent;
        _receiveBlocState(event.blocId, event.event);
        break;
      case InvokePlatformChannelEvent:
        event = event as InvokePlatformChannelEvent;
        _methodChannelMiddleware.send(event.channel, event.data, event.id);
        break;
      case MethodChannelResponseEvent:
        event = event as MethodChannelResponseEvent;
        _methodChannelMiddleware.methodChannelResponse(event.id, event.data);
        break;
      default:
        throw Exception('This is internal error. If you face it please create issue\n'
            'Unknown `ServiceEvent` with type ${event.runtimeType}');
    }
  }

  /// Finish [IsolateBlocBase] creating which started by call [createBloc].
  /// Connect [IsolateBlocBase] to it's [IsolateBlocWrapper].
  void _onBlocCreated(String id) {
    final wrapper = _wrappers[id];
    if (wrapper != null) {
      // ignore: invalid_use_of_protected_member
      wrapper.onBlocCreated();
    }
  }

  /// Call when new state from [IsolateBlocBase] received.
  /// Find wrapper by bloc id and add new state to it.
  void _receiveBlocState(String blocId, Object? state) {
    // ignore: invalid_use_of_protected_member
    _wrappers[blocId]?.stateReceiver(state);
  }
}

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = FutureOr Function();

typedef IsolateManagerCreator = Future<IsolateCreateResult> Function(
  IsolateRun,
  Initializer,
  List<String> channels,
);

typedef InitialStates = Map<Type, Object?>;
