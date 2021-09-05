import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_builder.dart';

/// {@template bloc_selector}
/// [IsolateBlocSelector] is analogous to [BlocBuilder] but allows developers to
/// filter updates by selecting a new value based on the bloc state.
/// Unnecessary builds are prevented if the selected value does not change.
///
/// **Note**: the selected value must be immutable in order for [IsolateBlocSelector]
/// to accurately determine whether [builder] should be called again.
///
/// ```dart
/// IsolateBlocSelector<BlocA, BlocAState, SelectedState>(
///   selector: (state) {
///     // return selected state based on the provided state.
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class IsolateBlocSelector<B extends IsolateBlocBase<Object?, S>, S, T> extends StatefulWidget {
  /// {@macro bloc_selector}
  const IsolateBlocSelector({
    Key? key,
    required this.selector,
    required this.builder,
    this.bloc,
  }) : super(key: key);

  /// The [bloc] that the [IsolateBlocSelector] will interact with.
  /// If omitted, [IsolateBlocSelector] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  final IsolateBlocWrapper? bloc;

  /// The [builder] function which will be invoked
  /// when the selected state changes.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [BlocBuilder].
  final BlocWidgetBuilder<T> builder;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current state.
  final BlocWidgetSelector<S, T> selector;

  @override
  State<IsolateBlocSelector<B, S, T>> createState() => _IsolateBlocSelectorState<B, S, T>();
}

class _IsolateBlocSelectorState<B extends IsolateBlocBase<Object?, S>, S, T> extends State<IsolateBlocSelector<B, S, T>> {
  late IsolateBlocWrapper _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.isolateBloc<B, S>();
    _state = widget.selector(_bloc.state);
  }

  @override
  void didUpdateWidget(IsolateBlocSelector<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.isolateBloc<B, S>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.isolateBloc<B, S>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    // todo(maksim)
    // if (widget.bloc == null) context.select<B, int>(identityHashCode);
    return IsolateBlocListener<B, S>(
      bloc: _bloc,
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder(context, _state),
    );
  }
}

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [state].
typedef BlocWidgetSelector<S, T> = T Function(S state);
