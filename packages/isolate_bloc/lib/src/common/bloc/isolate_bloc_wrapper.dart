import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

/// Signature for event receiver function which takes an [IsolateBlocTransitionEvent]
/// and send this event to the [IsolateBloc]
typedef EventReceiver = void Function(IsolateBlocTransitionEvent<Object> event);

/// Signature for function which takes [IsolateBloc]'s uuid and close it
typedef IsolateBlocKiller = void Function(String? uuid);

/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output using [IsolateBloc].
///
/// It is work like a client for [IsolateBloc]. It receives [IsolateBloc]'s
/// states and send events added by `wrapperInstance.add(YourEvent())`. So you can
/// listen for origin bloc's state with `wrapperInstance.listen((state) { })` and add
/// events as shown above.
///
/// [createBloc] function creates [IsolateBloc] in [Isolate] and return this object.
class IsolateBlocWrapper<State extends Object> implements Sink<Object> {
  /// Receives initialState, function which receive events and send them to the
  /// origin [IsolateBloc] and function which called in [close] and close origin bloc.
  @protected
  IsolateBlocWrapper({
    State? state,
    required EventReceiver eventReceiver,
    required IsolateBlocKiller onBlocClose,
  })  : _eventReceiver = eventReceiver,
        _onBlocClose = onBlocClose,
        _state = state {
    _bindEventsListener();
  }

  /// Create object as default constructor do but without initialState.
  IsolateBlocWrapper.noInitState(
    this._eventReceiver,
    this._onBlocClose,
  ) : _state = null {
    _bindEventsListener();
  }

  final _eventController = StreamController<Object>.broadcast();
  final _stateController = StreamController<State>.broadcast();

  /// Id of IsolateBloc. It's needed to find bloc in isolate.
  String? _isolateBlocUuid;

  State? _state;
  final _unsentEvents = <Object>[];
  final IsolateBlocKiller _onBlocClose;
  late StreamSubscription<Object> _eventReceiverSubscription;

  /// Returns stream with `event`
  Stream<Object> get eventStream => _eventController.stream;

  /// Callback which receive events and send them to the IsolateBloc
  final EventReceiver _eventReceiver;

  /// Returns the current [state] of the [bloc].
  State get state => _state!;

  /// Returns the stream of states
  Stream<State> get stream => _stateController.stream;

  /// As a result, call original [IsolateBloc]'s add function.
  @override
  void add(Object event) {
    _eventController.add(event);
  }

  /// Closes the `event` stream and request to close [IsolateBloc]
  @override
  @mustCallSuper
  Future<void> close() async {
    _onBlocClose(_isolateBlocUuid);
    await _eventController.close();
    await _stateController.close();
    await _eventReceiverSubscription.cancel();
  }

  /// Connects this wrapper to the [IsolateBloc] and sends all unsent events.
  @protected
  void connectToBloc(String uuid) {
    _isolateBlocUuid = uuid;
    while (_unsentEvents.isNotEmpty) {
      _eventReceiver(IsolateBlocTransitionEvent<Object>(
        uuid,
        _unsentEvents.removeAt(0),
      ));
    }
  }

  /// Receives [IsolateBloc]'s state and add to the state Stream.
  @protected
  void stateReceiver(State nextState) {
    if (nextState != state) {
      _stateController.add(nextState);
      _state = nextState;
    }
  }

  /// Starts listening for new `events`
  void _bindEventsListener() {
    _eventReceiverSubscription = eventStream.listen((event) {
      final uuid = _isolateBlocUuid;
      if (uuid != null) {
        _eventReceiver(IsolateBlocTransitionEvent<Object>(uuid, event));
      } else {
        _unsentEvents.add(event);
      }
    });
  }
}
