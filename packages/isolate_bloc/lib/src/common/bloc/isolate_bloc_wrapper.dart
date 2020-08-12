import 'dart:async';

import 'package:flutter/foundation.dart';
import 'isolate_bloc.dart';
import '../isolate/service_events.dart';

import 'transition.dart';

/// Signature for event receiver function which takes an [IsolateBlocTransitionEvent]
/// and send this event to the [IsolateBloc]
typedef EventReceiver = void Function(IsolateBlocTransitionEvent<Object> event);

/// Signature for function which takes [IsolateBloc]'s uuid and close it
typedef IsolateBlocKiller = void Function(String uuid);

/// [IsolateBlocWrapper] work like a client for [IsolateBloc]. It receives [IsolateBloc]'s
/// states and send events added by `wrapperInstance.add(YourEvent())`. So you can
/// listen for origin bloc's state with `wrapperInstance.listen((state) { })` and add
/// events as shown above.
/// createBloc function create [IsolateBloc] in [Isolate] and return this object.
class IsolateBlocWrapper<State> extends Stream<State> implements Sink<Object> {
  final _eventController = StreamController<Object>.broadcast();
  final _stateController = StreamController<State>.broadcast();

  /// Id of IsolateBloc. It's needed to find bloc in isolate.
  String _originBlocUuid;

  State _state;
  bool _initStateProvided;
  final _unsentEvents = <Object>[];
  final IsolateBlocKiller _onBlocClose;
  StreamSubscription<Transition<Object, State>> _stateTransitionSubscription;
  StreamSubscription<Object> _eventReceiverSubscription;

  /// Returns stream with `event`
  Stream<Object> get eventStream => _eventController.stream;

  /// Callback which receive events and send them to the IsolateBloc
  final EventReceiver _eventReceiver;

  /// Returns the current [state] of the [bloc].
  State get state => _state;

  /// Returns whether the `Stream<State>` is a broadcast stream.
  @override
  bool get isBroadcast => _stateController.stream.isBroadcast;

  /// Receives initialState, function which receive events and send them to the
  /// origin [IsolateBloc] and function which called in [close] and close origin bloc.
  IsolateBlocWrapper(
    this._state,
    this._eventReceiver,
    this._onBlocClose,
  ) : _initStateProvided = true {
    _bindEventsListener();
  }

  /// Create object as default constructor do but without initialState.
  IsolateBlocWrapper.noInitState(
    this._eventReceiver,
    this._onBlocClose,
  )   : _state = null,
        _initStateProvided = false {
    _bindEventsListener();
  }

  /// Adds a subscription to the `Stream<State>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<State>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<State> listen(
    void Function(State) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return _prepareStateStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  Stream<State> get _prepareStateStream async* {
    if (_initStateProvided) {
      yield state;
    }
    yield* _stateController.stream;
  }

  /// As a result, call original [IsolateBloc]'s add function.
  @override
  void add(Object event) {
    _eventController.add(event);
  }

  /// Closes the `event` stream and request to close [IsolateBloc]
  @override
  @mustCallSuper
  Future<void> close() async {
    _onBlocClose(_originBlocUuid);
    await _eventController.close();
    await _stateController.close();
    await _stateTransitionSubscription?.cancel();
    await _eventReceiverSubscription?.cancel();
  }

  /// Connect this wrapper to the origin [IsolateBloc] and start listening for state.
  void connectToBloc(String uuid) {
    assert(uuid != null);
    _originBlocUuid = uuid;
    while (_unsentEvents.isNotEmpty) {
      _eventReceiver(IsolateBlocTransitionEvent<Object>(
        _originBlocUuid,
        _unsentEvents.removeAt(0),
      ));
    }
  }

  /// Receive [IsolateBloc]'s state and add to the state Stream.
  void stateReceiver(State nextState) {
    _initStateProvided = true;
    if (nextState != state) {
      _stateController.add(nextState);
    }
    _state = nextState;
  }

  /// Start listening for new `events`
  void _bindEventsListener() {
    _eventReceiverSubscription = eventStream.listen((event) {
      if (_originBlocUuid != null) {
        _eventReceiver(
            IsolateBlocTransitionEvent<Object>(_originBlocUuid, event));
      } else {
        _unsentEvents.add(event);
      }
    });
  }
}
