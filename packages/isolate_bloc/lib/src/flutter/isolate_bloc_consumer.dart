import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';

/// {@template bloc_consumer}
/// [IsolateBlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [IsolateBlocConsumer] is analogous to a nested `BlocListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [IsolateBlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [blocWrapper].
///
/// [IsolateBlocConsumer] takes a required `BlocWidgetBuilder`
/// and `IsolateBlocWidgetListener` and an optional [blocWrapper],
/// `BlocBuilderCondition`, and `BlocListenerCondition`.
///
/// If the [blocWrapper] parameter is omitted, [IsolateBlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// IsolateBlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [blocWrapper] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [blocWrapper] when
/// the [IsolateBlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// IsolateBlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
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
class IsolateBlocConsumer<C extends IsolateBloc<Object, S>, S>
    extends StatelessWidget {
  /// {@macro bloc_consumer}
  const IsolateBlocConsumer({
    Key key,
    @required this.builder,
    @required this.listener,
    this.blocWrapper,
    this.buildWhen,
    this.listenWhen,
  })  : assert(builder != null),
        assert(listener != null),
        super(key: key);

  /// The [blocWrapper] that the [IsolateBlocConsumer] will interact with.
  /// If omitted, [IsolateBlocConsumer] will automatically perform a lookup using
  /// `IsolateBlocProvider` and the current `BuildContext`.
  final IsolateBlocWrapper<S> blocWrapper;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final IsolateBlocWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [blocWrapper] `state`
  /// and is responsible for executing in response to `state` changes.
  final IsolateBlocWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final IsolateBlocBuilderCondition<S> buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [IsolateBlocConsumer] with the current `state`.
  final IsolateBlocListenerCondition<S> listenWhen;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = blocWrapper ?? context.isolateBloc<C, S>();
    return IsolateBlocListener<C, S>(
      isolateBloc: bloc,
      listener: listener,
      listenWhen: listenWhen,
      child: IsolateBlocBuilder<C, S>(
        isolateBloc: bloc,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }
}
