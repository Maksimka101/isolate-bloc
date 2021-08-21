import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import '../common/bloc/isolate_bloc.dart';
import '../common/bloc/isolate_bloc_wrapper.dart';
import 'isolate_bloc_provider.dart';

/// Mixin which allows `IsolateMultiBlocListener` to infer the types
/// of multiple [IsolateBlocListener]s.
mixin IsolateBlocListenerSingleChildWidget on SingleChildWidget {}

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef IsolateBlocWidgetListener<S> = void Function(
  BuildContext context,
  S state,
);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [IsolateBlocWidgetListener] of [IsolateBlocListener]
/// with the current `state`.
typedef IsolateBlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloc_listener}
/// Takes a [IsolateBlocWidgetListener] and an optional [isolateBloc] and invokes
/// the [listener] in response to `state` changes in the [isolateBloc].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///
/// If the [isolateBloc] parameter is omitted, [IsolateBlocListener] will automatically
/// perform a lookup using [IsolateBlocProvider] and the current `BuildContext`.
///
/// ```dart
/// IsolateBlocListener<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [isolateBloc] if you wish to provide a [isolateBloc] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// IsolateBlocListener<BlocA, BlocAState>(
///   bloc: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [isolateBloc] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [isolateBloc]
/// when the [IsolateBlocListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// IsolateBlocListener<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   }
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class IsolateBlocListener<C extends IsolateBloc<Object, S>, S extends Object> extends IsolateBlocListenerBase<C, S>
    with IsolateBlocListenerSingleChildWidget {
  /// {@macro bloc_listener}
  const IsolateBlocListener({
    Key? key,
    required IsolateBlocWidgetListener<S> listener,
    IsolateBlocWrapper<S>? isolateBloc,
    IsolateBlocListenerCondition<S>? listenWhen,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          isolateBloc: isolateBloc,
          listenWhen: listenWhen,
        );
}

/// {@template bloc_listener_base}
/// Base class for widgets that listen to state changes in a specified [isolateBloc].
///
/// A [IsolateBlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class IsolateBlocListenerBase<C extends IsolateBloc<Object, S>, S extends Object>
    extends SingleChildStatefulWidget {
  /// {@macro bloc_listener_base}
  const IsolateBlocListenerBase({
    Key? key,
    this.listener,
    this.isolateBloc,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// The widget which will be rendered as a descendant of the
  /// [IsolateBlocListenerBase].
  final Widget? child;

  /// The [isolateBloc] whose `state` will be listened to.
  /// Whenever the [isolateBloc]'s `state` changes, [listener] will be invoked.
  final IsolateBlocWrapper<S>? isolateBloc;

  /// The [IsolateBlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final IsolateBlocWidgetListener<S>? listener;

  /// {@macro bloc_listener_listen_when}
  final IsolateBlocListenerCondition<S>? listenWhen;

  @override
  SingleChildState<IsolateBlocListenerBase<C, S>> createState() => _BlocListenerBaseState<C, S>();
}

class _BlocListenerBaseState<C extends IsolateBloc<Object, S>, S extends Object>
    extends SingleChildState<IsolateBlocListenerBase<C, S>> {
  StreamSubscription<S>? _subscription;
  S? _previousState;
  IsolateBlocWrapper<S>? _isolateBlocWrapper;

  @override
  void initState() {
    super.initState();
    _isolateBlocWrapper = widget.isolateBloc ?? context.isolateBloc<C, S>();
    _previousState = _isolateBlocWrapper?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(IsolateBlocListenerBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ignore: close_sinks
    final oldCubit = oldWidget.isolateBloc ?? context.isolateBloc<C, S>();
    // ignore: close_sinks
    final currentCubit = widget.isolateBloc ?? oldCubit;
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _isolateBlocWrapper = widget.isolateBloc ?? context.isolateBloc<C, S>();
        _previousState = _isolateBlocWrapper?.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_isolateBlocWrapper != null) {
      _subscription = _isolateBlocWrapper?.stream.listen((state) {
        if (widget.listenWhen?.call(_previousState!, state) ?? true) {
          widget.listener?.call(context, state);
        }
        _previousState = state;
      });
    }
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
