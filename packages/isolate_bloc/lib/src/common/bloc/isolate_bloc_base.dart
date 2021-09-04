import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/change.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_cubit.dart';

/// This is an exception which is thrown on exception in `add` function in debug mode
class BlocUnhandledErrorException implements Exception {
  BlocUnhandledErrorException(this.bloc, this.error, [this.stackTrace]);

  /// The [bloc] in which the unhandled error occurred.
  final IsolateBlocBase bloc;

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

/// {@template bloc_stream}
/// An interface for the core functionality implemented by
/// both [IsolateCubit] and [IsolateBloc].
/// {@endtemplate}
abstract class IsolateBlocBase<Event, State> implements Sink<Event> {
  /// {@macro bloc_stream}
  // todo(maksim): maybe we should move initial state to the `register` function
  IsolateBlocBase(this._state) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onCreate(this);
  }

  final _unsentStates = Queue<State>();

  StreamController<State>? __stateController;
  StreamController<State> get _stateController {
    return __stateController ??= StreamController<State>.broadcast();
  }

  State _state;

  bool _emitted = false;

  /// Whenever first emit is called
  bool get emitted => _emitted;

  /// This is bloc's id. Every [IsolateBlocBase] have it's own unique id used to
  /// communicate with it's own [IsolateBlocWrapper].
  ///
  /// It is not guaranteed that [_id] will be set after creation and before first event
  String? _id;

  String? get id => _id;
  
  /// Sets [_id] and emits all [_unsentStates]
  set id(String? id) {
    _id = id;
    while (_unsentStates.isNotEmpty) {
      emit(_unsentStates.removeFirst());
    }
  }

  /// The current [state].
  State get state => _state;

  /// The current state stream.
  Stream<State> get stream => _stateController.stream;

  /// Whether the bloc is closed.
  ///
  /// A bloc is considered closed once [close] is called.
  /// Subsequent state changes cannot occur within a closed bloc.
  bool get isClosed => _stateController.isClosed;

  /// Notifies the [IsolateBlocBase] of a new event and calls [onEventReceived]
  @override
  void add(Event event) {
    try {
      onEvent(event);
      onEventReceived(event);
    } catch (e, stackTrace) {
      onError(e, stackTrace);
    }
  }

  /// This function receive events from UI.
  void onEventReceived(Event event);

  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the instance has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the instance.
  void emit(State state) {
    if (_stateController.isClosed || state == _state && _emitted) {
      return;
    }

    if (_id == null) {
      // this state will be emitted when [_id] will be set
      _unsentStates.add(state);
      return;
    }

    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
    _emitted = true;
  }

  /// Called whenever an [event] is [add]ed to the [Bloc].
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  ///
  /// **Note: `super.onEvent` should always be called first.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  ///
  ///   // Custom onEvent logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver.onEvent] for observing events globally.
  ///
  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onEvent(this, event);
  }

  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `cubit` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `cubit`.
  ///
  /// **Note: `super.onChange` should always be called first.**
  /// ```dart
  /// @override
  /// void onChange(Change change) {
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  ///
  ///   // Custom onChange logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Cubit] behavior globally.
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onChange(this, change);
  }

  /// Reports an [error] which triggers [onError] with an optional [StackTrace].
  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  /// Called whenever an [error] occurs and notifies [BlocObserver.onError].
  ///
  /// In debug mode, [onError] throws a [BlocUnhandledErrorException] for
  /// improved visibility.
  ///
  /// In release mode, [onError] does not throw and will instead only report
  /// the error to [BlocObserver.onError].
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
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onError(this, error, stackTrace);
    assert(() {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Free all resources. This method should be called when instance is no
  /// longer needed. Once close is called, events that are added will not be
  /// processed.
  @override
  @mustCallSuper
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    IsolateBloc.observer.onClose(this);
    await _stateController.close();
  }
}
