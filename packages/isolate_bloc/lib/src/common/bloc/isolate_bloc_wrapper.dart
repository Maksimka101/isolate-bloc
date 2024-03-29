import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:uuid/uuid.dart';

/// Signature for event receiver function which takes an [IsolateBlocTransitionEvent]
/// and send this event to the [IsolateBloc]
typedef EventReceiver = void Function(Object? event);

/// Signature for function which takes [IsolateBloc]'s uuid and close it
typedef IsolateBlocKiller = void Function(String uuid);

/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output using [IsolateBlocBase].
///
/// It works like a client for [IsolateBlocBase]. It receives [IsolateBlocBase]'s
/// states and sends events added by `wrapperInstance.add(YourEvent())`. So you can
/// listen for origin bloc's state with `wrapperInstance.listen((state) { })` and add
/// events as shown above.
///
/// It may be created:
///   * by [createBloc] function which creates [IsolateBlocBase] in `Isolate`
///     and returns the instance of this class.
///   * by [getBloc] function which creates the instance of this class
///     and connects it to the [IsolateBlocBase]
///
/// Don't create this manually!
class IsolateBlocWrapper<State> {
  /// Takes initialState ([state]), function which receives events
  /// and sends them to the [IsolateBlocBase]
  /// and function which called on [close] and closes [IsolateBlocBase]
  /// which is connected to this wrapper.
  @protected
  IsolateBlocWrapper({
    State? state,
    required EventReceiver eventReceiver,
    required IsolateBlocKiller onBlocClose,
  })  : _eventReceiver = eventReceiver,
        _onBlocClose = onBlocClose,
        _state = state,
        isolateBlocId = isolateBlocIdGenerator() {
    _bindEventsListener();
  }

  /// Creates wrapper for [getBloc] functionality
  @protected
  IsolateBlocWrapper.isolate(
    this._eventReceiver,
    this._onBlocClose, [
    State? state,
  ]) : _state = state {
    _bindEventsListener();
  }

  /// Id of IsolateBloc. It's needed to find bloc in isolate.
  ///
  /// This id may be changed.
  @protected
  String? isolateBlocId;

  final _eventController = StreamController<Object?>.broadcast();
  final _stateController = StreamController<State>.broadcast();

  State? _state;

  /// Used to sync unsent events.
  var _blocCreated = false;
  final _unsentEvents = Queue<Object?>();
  final IsolateBlocKiller _onBlocClose;
  late StreamSubscription<Object?> _eventReceiverSubscription;

  /// Callback which receives events and sends them to the IsolateBloc.
  final EventReceiver _eventReceiver;

  /// Returns the current [state] of the [bloc].
  ///
  /// It may be null only in wrapper provided by `getBlocWrapperFunction`.
  /// Can't be null in UI isolate.
  State? get state => _state;

  /// Returns the stream of states.
  Stream<State> get stream => _stateController.stream;

  /// Returns stream of `event`.
  Stream<Object?> get _eventStream => _eventController.stream;

  /// As a result, call original [IsolateBloc]'s add function.
  void add(Object? event) {
    _eventController.add(event);
  }

  /// Closes the `event` stream and requests to close connected [IsolateBlocBase].
  @mustCallSuper
  Future<void> close() async {
    final id = isolateBlocId;
    if (id != null) {
      _onBlocClose(id);
    }
    await _eventController.close();
    await _stateController.close();
    await _eventReceiverSubscription.cancel();
  }

  /// Connects this wrapper to the [IsolateBlocBase] and sends all unsent events.
  // TODO(Maksim): Maybe move unsent events synchronization to the [IsolateManager]
  @protected
  void onBlocCreated() {
    _blocCreated = true;
    while (_unsentEvents.isNotEmpty) {
      _eventReceiver(_unsentEvents.removeFirst());
    }
  }

  /// Receives [IsolateBlocBase]'s states and adds them to the state Stream.
  @protected
  void stateReceiver(State nextState) {
    if (nextState != _state) {
      _stateController.add(nextState);
      _state = nextState;
    }
  }

  /// Starts listening for new `events`.
  void _bindEventsListener() {
    _eventReceiverSubscription = _eventStream.listen((event) {
      if (_blocCreated) {
        _eventReceiver(event);
      } else {
        _unsentEvents.add(event);
      }
    });
  }
}

/// Signature for [IsolateBlocWrapper] id generator.
typedef IdGenerator = String Function();

/// This function is used to generate id for [IsolateBlocWrapper].
///
/// By default uses `uuid v4` generator.
IdGenerator isolateBlocIdGenerator = const Uuid().v4;
