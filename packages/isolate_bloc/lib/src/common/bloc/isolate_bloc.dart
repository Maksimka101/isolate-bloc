import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:uuid/uuid.dart';

import 'isolate_bloc_observer.dart';
import 'transition.dart';

class BlocUnhandledErrorException implements Exception {
  /// The [bloc] in which the unhandled error occurred.
  final IsolateBloc bloc;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace stackTrace;

  /// {@macro bloc_unhandled_error_exception}
  BlocUnhandledErrorException(this.bloc, this.error, [this.stackTrace]);

  @override
  String toString() {
    return 'Unhandled error $error occurred in bloc $bloc.\n'
        '${stackTrace ?? ''}';
  }
}

/// This bloc works in isolate.
/// [IsolateBlocWrapper]<Event>, State> will receive this bloc's state.
/// This bloc must be created from UI with `createBloc<BlocT, BlocTState>`
/// function or `IsolateBlocProvider<BlocT, BlocTState>()`.
/// You can use it from another [IsolateBloc] with `getBloc<BlocT>()`
/// or `getBlocWrapper<BlocT, BlocTState>()`.
abstract class IsolateBloc<Event, State> extends Stream<State>
    implements Sink<State> {
  State _state;
  Event _event;

  /// This is bloc's id. Every [IsolateBloc] have it's own unique id used to
  /// communicate with it's own [IsolateBlocWrapper].
  final String id;
  final _stateController = StreamController<State>.broadcast();
  StreamSubscription<State> _stateSubscription;

  /// The current [IsolateBlocObserver].
  static IsolateBlocObserver observer = IsolateBlocObserver();

  /// Returns the current [state] of the [IsolateBloc].
  State get state => _state;

  /// Basic constructor. Gain initial state and generate bloc's id;
  IsolateBloc(this._state) : id = Uuid().v4() {
    _bindStateReceiver();
  }

  /// Notifies the [IsolateBloc] of a new event which triggers onEventReceived.
  @mustCallSuper
  @override
  void add(Object event) {
    try {
      _event = event;
      onEvent(event);
      onEventReceived(event);
    } catch (e, stackTrace) {
      onError(e, stackTrace);
    }
  }

  /// Use this function to send new state to UI.
  @mustCallSuper
  void emit(State state) {
    _stateController.add(state);
  }

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and `state`
  /// from `emit` received.
  /// [onTransition] is called before a [bloc]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [bloc] level.
  ///
  /// **Note: `super.onTransition` should always be called last.**
  /// ```dart
  /// @override
  /// void onTransition(Transition<Event, State> transition) {
  ///   // Custom onTransition logic goes here
  ///
  ///   // Always call super.onTransition with the current transition
  ///   super.onTransition(transition);
  /// }
  /// ```
  @mustCallSuper
  void onTransition(Transition<Object, State> transition) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onTransition(this, transition);
  }

  /// Called whenever an [event] is [add]ed to the [bloc].
  /// A great spot to add logging/analytics at the individual [bloc] level.
  ///
  /// **Note: `super.onEvent` should always be called last.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Custom onEvent logic goes here
  ///
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  /// }
  /// ```
  @mustCallSuper
  void onEvent(Object event) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onEvent(this, event);
  }

  /// Called whenever an [error] is thrown within onTransition in [IsolatedBloc].
  /// By default all [error]s will be ignored and [bloc] functionality will be
  /// unaffected.
  /// The [stackTrace] argument may be `null` if the [state] stream received
  /// an error without a [stackTrace].
  /// A great spot to handle errors at the individual [IsolateBlocWrapper] level.
  ///
  /// **Note: `super.onError` should always be called last.**
  /// ```dart
  /// @override
  /// void onError(Object error, StackTrace stackTrace) {
  ///   // Custom onError logic goes here
  ///
  ///   // Always call super.onError with the current error and stackTrace
  ///   super.onError(error, stackTrace);
  /// }
  /// ```
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onError(this, error, stackTrace);
    if (kDebugMode) {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }
  }

  /// Adds a subscription to the Stream<State>. Returns a StreamSubscription
  /// which handles events from the Stream<State> using the provided onData,
  /// onError and onDone handlers.
  @override
  StreamSubscription<State> listen(
    void Function(State event) onData, {
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
    yield state;
    yield* _stateController.stream;
  }

  /// This function receive events from UI.
  void onEventReceived(Event event);

  void _bindStateReceiver() {
    _stateSubscription = _stateController.stream.listen((nextState) {
      final transition = Transition(
        currentState: state,
        event: _event,
        nextState: nextState,
      );

      try {
        onTransition(transition);
        _state = transition.nextState;
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    });
  }

  /// Free all resources. This method should be called when a IsolateBloc is no
  /// longer needed. Once close is called, events that are added will not be
  /// processed.
  @override
  @mustCallSuper
  Future<void> close() async {
    await _stateSubscription.cancel();
    await _stateController.close();
  }
}
