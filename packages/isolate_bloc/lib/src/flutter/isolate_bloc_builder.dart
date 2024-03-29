import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_listener.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_provider.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [IsolateBlocBuilder] with the current `state`.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

/// {@template bloc_builder}
/// [IsolateBlocBuilder] handles building a widget in response to new `states`.
/// [IsolateBlocBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [bloc]-specific
/// performance improvements.

/// Please refer to [IsolateBlocListener] if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [bloc] parameter is omitted, [IsolateBlocBuilder] will automatically
/// perform a lookup using [IsolateBlocProvider] and the current [BuildContext].
///
/// ```dart
/// IsolateBlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
/// not accessible via [IsolateBlocProvider] and the current [BuildContext].
///
/// ```dart
/// IsolateBlocBuilder<BlocA, BlocAState>(
///   bloc: blocA,
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
///
/// {@template bloc_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [IsolateBlocBuilder] rebuilds.
/// [buildWhen] should only be used for performance optimizations as it
/// provides no security about the state passed to the [builder] function.
/// [buildWhen] will be invoked on each [bloc] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
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
/// )
/// ```
/// {@endtemplate}
class IsolateBlocBuilder<B extends IsolateBlocBase<Object?, S>, S>
    extends IsolateBlocBuilderBase<B, S> {
  /// {@macro bloc_builder}
  /// {@macro bloc_builder_build_when}
  const IsolateBlocBuilder({
    Key? key,
    required this.builder,
    IsolateBlocWrapper? bloc,
    BlocBuilderCondition<S>? buildWhen,
  }) : super(key: key, bloc: bloc, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// {@template bloc_builder_base}
/// Base class for widgets that build themselves based on interaction with
/// a specified [bloc].
///
/// A [IsolateBlocBuilderBase] is stateful and maintains the state of the interaction
/// so far. The type of the state and how it is updated with each interaction
/// is defined by sub-classes.
/// {@endtemplate}
abstract class IsolateBlocBuilderBase<B extends IsolateBlocBase<Object?, S>, S>
    extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const IsolateBlocBuilderBase({Key? key, this.bloc, this.buildWhen})
      : super(key: key);

  /// The [bloc] that the [IsolateBlocBuilderBase] will interact with.
  /// If omitted, [IsolateBlocBuilderBase] will automatically perform a lookup using
  /// [IsolateBlocProvider] and the current `BuildContext`.
  final IsolateBlocWrapper? bloc;

  /// {@macro bloc_builder_build_when}
  final BlocBuilderCondition<S>? buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<IsolateBlocBuilderBase<B, S>> createState() =>
      _IsolateBlocBuilderBaseState<B, S>();
}

class _IsolateBlocBuilderBaseState<B extends IsolateBlocBase<Object?, S>, S>
    extends State<IsolateBlocBuilderBase<B, S>> {
  late IsolateBlocWrapper _bloc;
  late S _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.isolateBloc<B, S>();
    _state = _bloc.state!;
  }

  @override
  void didUpdateWidget(IsolateBlocBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.isolateBloc<B, S>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.isolateBloc<B, S>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IsolateBlocListener<B, S>(
      bloc: _bloc,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }
}
