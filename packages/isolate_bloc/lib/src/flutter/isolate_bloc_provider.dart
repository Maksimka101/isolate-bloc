import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../common/api_wrappers.dart';
import '../common/bloc/isolate_bloc.dart';
import '../common/bloc/isolate_bloc_wrapper.dart';
import './bloc_info_holder.dart';

/// A function that creates a `Bloc` of type [T].
typedef CreateIsolateBloc<T extends IsolateBloc<Object, Object>> = T Function(
  BuildContext context,
);

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [IsolateBlocProvider]s.
mixin IsolateBlocProviderSingleChildWidget on SingleChildWidget {}

/// {@template bloc_provider}
/// Takes a `ValueBuilder` that is responsible for creating the `bloc` and
/// a [child] which will have access to the `bloc` via
/// `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a `bloc` can be provided to multiple widgets within a subtree.
///
/// Automatically handles closing the `bloc` when used with `create`.
///
/// ```dart
/// IsolateBlocProvider(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class IsolateBlocProvider<T extends IsolateBloc<Object, State>,
        State extends Object> extends SingleChildStatelessWidget
    with IsolateBlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
  IsolateBlocProvider({
    Key? key,
    Widget? child,
  }) : this._(
          key: key,
          create: (_) => null,
          dispose: (_, bloc) => bloc?.close(),
          child: child,
        );

  /// Takes a `bloc` and a [child] which will have access to the `bloc` via
  /// `IsolateBlocProvider.of(context)`.
  /// When `IsolateBlocProvider.value` is used, the `bloc` will not be automatically
  /// closed.
  /// As a result, `IsolateBlocProvider.value` should mainly be used for providing
  /// existing `bloc`s to new routes.
  ///
  /// A new `bloc` should not be created in `IsolateBlocProvider.value`.
  /// `bloc`s should always be created using the default constructor within
  /// `create`.
  ///
  /// ```dart
  /// IsolateBlocProvider.value(
  ///   value: IsolateBlocProvider.of<BlocA, BlocAState>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  IsolateBlocProvider.value({
    Key? key,
    required IsolateBlocWrapper<Object> value,
    Widget? child,
  }) : this._(
          key: key,
          create: (_) => value,
          child: child,
        );

  /// Internal constructor responsible for creating the [IsolateBlocProvider].
  /// Used by the [IsolateBlocProvider] default and value constructors.
  IsolateBlocProvider._({
    Key? key,
    required Create<IsolateBlocWrapper<Object>?> create,
    Dispose<IsolateBlocWrapper?>? dispose,
    this.child,
  })  : _dispose = dispose,
        _create = create,
        super(key: key, child: child);

  /// [child] and its descendants which will have access to the `bloc`.
  final Widget? child;

  final Create<IsolateBlocWrapper<Object>?> _create;

  final Dispose<IsolateBlocWrapper?>? _dispose;

  /// Method that allows widgets to access a `cubit` instance as long as their
  /// `BuildContext` contains a [IsolateBlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// IsolateBlocProvider.of<BlocA, BlocAState>(context)
  /// ```
  static IsolateBlocWrapper<State>
      of<T extends IsolateBloc<Object, State>, State extends Object>(
          BuildContext context) {
    final blocInfoHolder = _getBlocInfoHolder(context);
    final blocWrapper = blocInfoHolder?.getWrapperByType<T, State>();
    if (blocWrapper == null) {
      throw FlutterError(
        '''
        IsolateBlocProvider.of() called with a context that does not contain a IsolateBlocWrapper for $T.
        No ancestor could be found starting from the context that was passed to IsolateBlocProvider.of<$T>().

        This can happen if you doesn't specify generic type or the context you used comes from a widget above the IsolateBlocProvider.

        The context used was: $context
        ''',
      );
    }
    return blocWrapper;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return InheritedProvider<BlocInfoHolder?>(
      create: (context) {
        var blocWrapper = _create.call(context);
        blocWrapper ??= createBloc<T, State>();
        if (blocWrapper == null) {
          print("Failed to create bloc");
          return null;
        }
        final blocInfoHolder = _getBlocInfoHolder(context) ?? BlocInfoHolder();
        blocInfoHolder.addBlocInfo<T>(blocWrapper);
        return blocInfoHolder;
      },
      dispose: (context, infoHolder) {
        _dispose?.call(context, infoHolder?.removeBloc<T>());
      },
      lazy: false,
      child: child,
    );
  }

  static BlocInfoHolder? _getBlocInfoHolder(BuildContext context) {
    try {
      return Provider.of<BlocInfoHolder>(context, listen: false);
    } catch (_) {
      return null;
    }
  }
}

/// Extends the `BuildContext` class with the ability
/// to perform a lookup based on a `Bloc` type.
extension IsolateBlocProviderExtension on BuildContext {
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor `Cubit` of type [C].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<C>(context)
  /// ```
  IsolateBlocWrapper<State> isolateBloc<C extends IsolateBloc<Object, State>,
      State extends Object>() {
    return IsolateBlocProvider.of<C, State>(this);
  }
}
