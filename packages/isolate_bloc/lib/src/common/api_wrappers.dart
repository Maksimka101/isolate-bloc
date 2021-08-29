import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';

/// Starts creating [IsolateBlocBase] and returns [IsolateBlocWrapper].
///
/// Throws [BlocManagerUnInitialized] if [blocManager] is null or in another words if you
/// didn't call [initialize] function before
IsolateBlocWrapper<State> createBloc<BlocT extends IsolateBlocBase<Object?, State>, State>() {
  final blocManager = BlocManager.instance;
  if (blocManager == null) {
    throw BlocManagerUnInitialized();
  } else {
    return blocManager.createBloc<BlocT, State>();
  }
}

/// Initialize [Isolate], ServiceEventListener in both Isolates and run [Initializer].
/// If already initialized and [recreate] is true kill previous [Isolate] and reinitialize everything.
Future<void> initialize(
  Initializer userInitializer, {
  PlatformChannelSetup platformChannelSetup = const PlatformChannelSetup(),
  bool recreate = false,
}) async {
  assert(
    !recreate && BlocManager.instance == null,
    'You can initialize only once. '
    'Call `initialize(..., reCreate: true)` if you want to reinitialize.',
  );
  return BlocManager.initialize(
    userInitializer,
    kIsWeb ? WebIsolateManagerFactory() : IOIsolateManagerFactory(),
    platformChannelSetup.methodChannels,
  );
}

class BlocManagerUnInitialized implements Exception {
  @override
  String toString() {
    return '$BlocManager must not be null. Call `await $initialize()`';
  }
}
