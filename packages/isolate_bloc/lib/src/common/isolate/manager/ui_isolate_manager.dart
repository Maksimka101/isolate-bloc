import 'dart:async';

import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_wrapper.dart';

/// Manager which is works in UI Isolate, responds on [IsolateBlocEvent]s from Isolate,
/// manages [IsolateBlocWrapper]s and implements [createBloc] global function.
class UIIsolateManager {
  /// Creates new manager and sets [instance].
  factory UIIsolateManager(IsolateCreateResult createResult) {
    return instance = UIIsolateManager._internal(
      createResult.isolate,
      createResult.messenger,
    );
  }

  UIIsolateManager._internal(
    this._isolate,
    this._isolateMessenger,
  );

  /// Instance of the last created manager.
  static UIIsolateManager? instance;

  final IIsolateWrapper _isolate;
  final IIsolateMessenger _isolateMessenger;

  InitialStates _initialStates = {};

  /// Map of [IsolateBlocWrapper] to it's id.
  final _wrappers = <String, IsolateBlocWrapper>{};
  StreamSubscription<IsolateEvent>? _serviceEventsSubscription;

  final _initializeCompleter = Completer<InitialStates>();

  /// Starts listening for [_isolateMessenger] and waits for [InitialStates].
  Future<void> initialize() async {
    _serviceEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is IsolateBlocEvent)
        .cast<IsolateBlocEvent>()
        .listen(_listenForIsolateBlocEvents);

    _initialStates = await _initializeCompleter.future;
  }

  /// {@macro create_bloc}
  IsolateBlocWrapper<S> createIsolateBloc<T extends IsolateBlocBase, S>() {
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

  /// Free all resources and kills [Isolate].
  Future<void> dispose() async {
    _isolate.kill();
    await _serviceEventsSubscription?.cancel();
  }

  /// Listens and respond on [IsolateBlocEvent]s from [IsolateManager].
  void _listenForIsolateBlocEvents(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocsInitialized:
        _initializeCompleter.complete(
          (event as IsolateBlocsInitialized).initialStates,
        );
        break;
      case IsolateBlocCreatedEvent:
        final createdEvent = event as IsolateBlocCreatedEvent;
        _onBlocCreated(createdEvent.blocId);
        break;
      case IsolateBlocTransitionEvent:
        final transitionEvent = event as IsolateBlocTransitionEvent;
        _receiveBlocState(transitionEvent.blocId, transitionEvent.event);
        break;

      default:
        throw Exception(
          'This is internal error. If you face it please create issue\n'
          'Unknown `ServiceEvent` with type ${event.runtimeType}',
        );
    }
  }

  /// Finishes [IsolateBlocBase] creating which started by call [createIsolateBloc].
  /// Connects [IsolateBlocWrapper] to it's [IsolateBlocBase].
  void _onBlocCreated(String id) {
    final wrapper = _wrappers[id];
    if (wrapper != null) {
      // ignore: invalid_use_of_protected_member
      wrapper.onBlocCreated();
    }
  }

  /// Finds wrapper by bloc id and adds new state to it.
  void _receiveBlocState(String blocId, Object? state) {
    // ignore: invalid_use_of_protected_member
    _wrappers[blocId]?.stateReceiver(state);
  }
}

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = FutureOr Function();

/// Signature for map with [IsolateBlocBase]s and their initial states.
typedef InitialStates = Map<Type, Object?>;
