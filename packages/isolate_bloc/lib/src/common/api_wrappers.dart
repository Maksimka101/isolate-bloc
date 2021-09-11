// ignore_for_file: prefer-match-file-name
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/initializer/isolate_initializer.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate/io_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Initialize [Isolate], ServiceEventListener in both Isolates and run [Initializer].
/// If already initialized and [recreate] is true kill previous [Isolate] and reinitialize everything.
Future<void> initialize(
  Initializer userInitializer, {
  MethodChannelSetup platformChannelSetup = const MethodChannelSetup(),
  bool recreate = false,
}) async {
  assert(
    !recreate && UIIsolateManager.instance == null || recreate,
    'You can initialize only once. '
    'Call `initialize(..., recreate: true)` if you want to reinitialize.',
  );

  return IsolateInitializer().initialize(
    userInitializer,
    kIsWeb ? WebIsolateFactory() : IOIsolateFactory(),
    platformChannelSetup.methodChannels,
  );
}

/// Starts creating [IsolateBlocBase] and returns [IsolateBlocWrapper].
///
/// Throws [UIIsolateManagerUnInitialized] if [UIIsolateManager] is null or in another words if you
/// didn't call [initialize] function before
IsolateBlocWrapper<State> createBloc<BlocT extends IsolateBlocBase<Object?, State>, State>() {
  final isolateManager = UIIsolateManager.instance;
  if (isolateManager == null) {
    throw UIIsolateManagerUnInitialized();
  } else {
    return isolateManager.createBloc<BlocT, State>();
  }
}

class UIIsolateManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$UIIsolateManager must not be null. Call `await initialize()`';
  }
}
