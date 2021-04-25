import 'dart:async';

import 'package:flutter/widgets.dart';

import '../common/bloc/isolate_bloc.dart';
import '../common/bloc/isolate_bloc_wrapper.dart';
import './isolate_bloc_provider.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef IsolateBlocWidgetBuilder<S> = Widget Function(
  BuildContext context,
  S state,
);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [IsolateBlocBuilder] with the current `state`.
typedef IsolateBlocBuilderCondition<S> = bool Function(S previous, S current);

/// {@template bloc_builder}
/// [IsolateBlocBuilder] handles building a widget in response to new `states`.
/// [IsolateBlocBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [isolateBloc]-specific
/// performance improvements.

/// Please refer to `BlocListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [isolateBloc] parameter is omitted, [IsolateBlocBuilder] will automatically
/// perform a lookup using [IsolateBlocProvider] and the current `BuildContext`.
///
/// ```dart
/// IsolateBlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [isolateBloc] if you wish to provide a [isolateBloc] that is otherwise
/// not accessible via [IsolateBlocProvider] and the current `BuildContext`.
///
/// ```dart
/// IsolateBlocBuilder<BlocA, BlocAState>(
///   cubit: blocA,
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
/// {@template bloc_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [IsolateBlocBuilder] rebuilds.
/// [buildWhen] will be invoked on each [isolateBloc] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [isolateBloc] when
/// the [IsolateBlocBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// IsolateBlocBuilder<BlocA, BlocAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
///)
/// ```
/// {@endtemplate}
class IsolateBlocBuilder<C extends IsolateBloc<Object, S>, S extends Object>
    extends IsolateBlocBuilderBase<C, S> {
  /// {@macro bloc_builder}
  const IsolateBlocBuilder({
    Key? key,
    required this.builder,
    IsolateBlocWrapper<S>? isolateBloc,
    IsolateBlocBuilderCondition<S>? buildWhen,
  }) : super(key: key, isolateBloc: isolateBloc, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final IsolateBlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// {@template bloc_builder_base}
/// Base class for widgets that build themselves based on interaction with
/// a specified [isolateBloc].
///
/// A [IsolateBlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
/// {@endtemplate}
abstract class IsolateBlocBuilderBase<C extends IsolateBloc<Object, S>,
    S extends Object> extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const IsolateBlocBuilderBase({
    Key? key,
    this.isolateBloc,
    this.buildWhen,
  }) : super(key: key);

  /// The [isolateBloc] that the [IsolateBlocBuilderBase] will interact with.
  /// If omitted, [IsolateBlocBuilderBase] will automatically perform a lookup using
  /// [IsolateBlocProvider] and the current `BuildContext`.
  final IsolateBlocWrapper<S>? isolateBloc;

  /// {@macro bloc_builder_build_when}
  final IsolateBlocBuilderCondition<S>? buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<IsolateBlocBuilderBase<C, S>> createState() =>
      _IsolateBlocBuilderBaseState<C, S>();
}

class _IsolateBlocBuilderBaseState<C extends IsolateBloc<Object, S>,
    S extends Object> extends State<IsolateBlocBuilderBase<C, S>> {
  StreamSubscription<S>? _subscription;
  S? _previousState;
  S? _state;
  IsolateBlocWrapper<S>? _blocWrapper;

  @override
  void initState() {
    super.initState();
    _blocWrapper = widget.isolateBloc ?? context.isolateBloc<C, S>();
    _previousState = _blocWrapper?.state;
    _state = _blocWrapper?.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(IsolateBlocBuilderBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ignore: close_sinks
    final oldIsolateBloc = oldWidget.isolateBloc ?? context.isolateBloc<C, S>();
    // ignore: close_sinks
    final currentBloc = widget.isolateBloc ?? oldIsolateBloc;
    if (oldIsolateBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _blocWrapper = widget.isolateBloc ?? context.isolateBloc<C, S>();
        _previousState = _blocWrapper?.state;
        _state = _blocWrapper?.state;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state!);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _blocWrapper?.listen((state) {
      if (widget.buildWhen?.call(_previousState!, state) ?? true) {
        setState(() {
          _state = state;
        });
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
