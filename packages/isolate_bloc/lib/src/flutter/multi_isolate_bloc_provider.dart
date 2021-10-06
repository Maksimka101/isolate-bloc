import 'package:flutter/widgets.dart';
import 'package:isolate_bloc/src/flutter/isolate_bloc_provider.dart';
import 'package:provider/provider.dart';

/// {@template multi_bloc_provider}
/// Merges multiple [IsolateBlocProvider] widgets into one widget tree.
///
/// [MultiIsolateBlocProvider] improves the readability and eliminates the need
/// to nest multiple [IsolateBlocProvider]s.
///
/// By using [MultiIsolateBlocProvider] we can go from:
///
/// ```dart
/// IsolateBlocProvider<BlocA, BlocAState>(
///   child: IsolateBlocProvider<BlocB, BlocBState>(
///     child: IsolateBlocProvider<BlocC, BlocCState>(
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiIsolateBlocProvider(
///   providers: [
///     IsolateBlocProvider<BlocA, BlocAState>(),
///     IsolateBlocProvider<BlocB, BlocBState>(),
///     IsolateBlocProvider<BlocC, BlocCState>(),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiIsolateBlocProvider] converts the [IsolateBlocProvider] list into a tree of nested
/// [IsolateBlocProvider] widgets.
/// As a result, the only advantage of using [MultiIsolateBlocProvider] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiIsolateBlocProvider extends MultiProvider {
  /// {@macro multi_bloc_provider}
  MultiIsolateBlocProvider({
    Key? key,
    required List<IsolateBlocProviderSingleChildWidget> providers,
    required Widget child,
  }) : super(key: key, providers: providers, child: child);
}
