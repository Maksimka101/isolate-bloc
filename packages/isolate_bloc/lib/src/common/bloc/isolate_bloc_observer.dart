import 'package:flutter/foundation.dart';

import 'isolate_bloc.dart';
import 'transition.dart';

/// An interface for observing the behavior of [IsolateBloc] instances.
class IsolateBlocObserver {
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
}
