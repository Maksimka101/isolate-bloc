import 'package:flutter/foundation.dart';

import 'isolate_bloc.dart';
import 'transition.dart';

/// An interface for observing the behavior of [IsolateBloc] instances.
class IsolateBlocObserver {
  /// Called whenever a [Bloc] is instantiated.
  /// In many cases, a cubit may be lazily instantiated and
  /// [onCreate] can be used to observe exactly when the cubit
  /// instance is created.
  @protected
  @mustCallSuper
  void onCreate(IsolateBloc bloc) {}

  /// Called whenever an [event] is `added` to any [bloc] with the given [bloc]
  /// and [event].
  @protected
  @mustCallSuper
  void onEvent(IsolateBloc bloc, Object event) {}

  /// Called whenever a transition occurs in any [bloc] with the given [bloc]
  /// and [transition].
  /// A [transition] occurs when a new `event` is `added` and `onEventReceived`
  /// executed.
  /// [onTransition] is called before a [bloc]'s state has been updated.
  @protected
  @mustCallSuper
  void onTransition(IsolateBloc bloc, Transition transition) {}

  /// Called whenever an [error] is thrown in any [bloc].
  /// The [stackTrace] argument may be `null` if the state stream received
  /// an error without a [stackTrace].
  @protected
  @mustCallSuper
  void onError(IsolateBloc bloc, Object error, StackTrace stackTrace) {}

  /// Called whenever a [Bloc] is closed.
  /// [onClose] is called just before the [Bloc] is closed
  /// and indicates that the particular instance will no longer
  /// emit new states.
  @protected
  @mustCallSuper
  void onClose(IsolateBloc bloc) {}
}
