// ignore_for_file: prefer-match-file-name
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/initializer/isolate_initializer.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate/io_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Initializes [UIIsolateManager] and [IsolateManager] in [Isolate] and runs [userInitializer].
///
/// If already initialized kills previous [Isolate] and creates new one.
///
/// Simply call this function at the start of main:
/// ```
/// Future<void> main() async {
///   await initialize(initializerFunc);
///
///   runApp(...);
/// }
///
/// void initializerFunc() {
///   register<Bloc, State>(create: () => Bloc());
/// }
/// ```
Future<void> initialize(
  Initializer userInitializer, {
  MethodChannelSetup platformChannelSetup = const MethodChannelSetup(),
}) async {
  return IsolateInitializer().initialize(
    userInitializer,
    kIsWeb ? WebIsolateFactory() : IOIsolateFactory(),
    platformChannelSetup.methodChannels,
  );
}

/// {@template create_bloc}
/// Starts creating [IsolateBlocBase] and returns [IsolateBlocWrapper].
///
/// Throws [UIIsolateManagerUnInitialized] if [UIIsolateManager] is null or in another words if you
/// didn't call [initialize] function before
///
/// How to use:
/// ```
/// // Create bloc.
/// final counterBloc = createBloc<CounterBloc, int>();
/// // Add event
/// counterBloc.add(CounterEvent.increment);
/// // Receive states.
/// counterBloc.stream.listen((state) => print('New state: $state')) // Prints "New state: 1".
/// ```
/// {@endtemplate}
IsolateBlocWrapper<S> createBloc<B extends IsolateBlocBase<Object?, S>, S>() {
  final isolateManager = UIIsolateManager.instance;
  if (isolateManager == null) {
    throw UIIsolateManagerUnInitialized();
  } else {
    return isolateManager.createIsolateBloc<B, S>();
  }
}

/// This exception indicates that [initialize] function wasn't called
class UIIsolateManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$UIIsolateManager must not be null. Call `await initialize()`';
  }
}
