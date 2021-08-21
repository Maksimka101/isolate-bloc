import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:uuid/uuid.dart';

import 'isolate_bloc_observer.dart';
import 'transition.dart';

/// This is an exception which is throws on exception in `add` function in debug mode
class BlocUnhandledErrorException implements Exception {
  BlocUnhandledErrorException(this.bloc, this.error, [this.stackTrace]);

  /// The [bloc] in which the unhandled error occurred.
  final IsolateBloc bloc;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in bloc $bloc.\n'
        '${stackTrace ?? ''}';
  }
}

/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
///
/// [IsolateBlocWrapper]<[Event]>, [State]> will receive this bloc's state.
/// This bloc must be created from UI with `createBloc<BlocT, BlocTState>`
/// function or `IsolateBlocProvider<BlocT, BlocTState>()`.
/// You can get it inside another [IsolateBloc] using `getBloc<BlocT>()`.
abstract class IsolateBloc<Event extends Object, State extends Object> implements Sink<State> {
  /// Basic constructor. Gains initial state and generates bloc's id;
  IsolateBloc(this._state) : id = const Uuid().v4() {
    // ignore: invalid_use_of_protected_member
    observer.onCreate(this);
    _bindStateReceiver();
  }

  State _state;
  Event? _event;

  /// This is bloc's id. Every [IsolateBloc] have it's own unique id used to
  /// communicate with it's own [IsolateBlocWrapper].
  final String id;
  final _stateController = StreamController<State>.broadcast();
  late StreamSubscription<State> _stateSubscription;

  /// The current [IsolateBlocObserver] instance.
  static IsolateBlocObserver observer = IsolateBlocObserver();

  /// Returns the current [state] of the [IsolateBloc].
  State get state => _state;

  /// Returns the stream of states
  Stream<State> get stream => _stateController.stream;

  /// Notifies the [IsolateBloc] of a new event which triggers onEventReceived.
  @mustCallSuper
  @override
  void add(Object event) {
    try {
      _event = event as Event;
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

  /// This function receive events from UI.
  void onEventReceived(Event event);

  void _bindStateReceiver() {
    _stateSubscription = _stateController.stream.listen((nextState) {
      final transition = Transition(
        currentState: state,
        event: _event!,
        nextState: nextState,
      );

      try {
        onTransition(transition);
        _state = transition.nextState;
      } catch (error, stackTrace) {
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
    // ignore: invalid_use_of_protected_member
    observer.onClose(this);
    await _stateSubscription.cancel();
    await _stateController.close();
  }
}
