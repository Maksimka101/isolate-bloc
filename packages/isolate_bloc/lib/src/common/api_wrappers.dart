import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/isolate_manager.dart';

import 'bloc/isolate_bloc.dart';
import 'bloc/isolate_bloc_wrapper.dart';
import 'isolate/bloc_manager.dart';
import 'isolate/platform_channel/platform_channel_setup.dart';

/// Starts creating [IsolateBloc] and returns [IsolateBlocWrapper].
///
/// Throws [BlocManagerUnInitialized] if [blocManager] is null or in another words if you
/// didn't call [initialize] function before
IsolateBlocWrapper<State> createBloc<BlocT extends IsolateBloc<Object, State>, State extends Object>() {
  final blocManager = BlocManager.instance;
  if (blocManager == null) {
    throw BlocManagerUnInitialized();
  } else {
    return blocManager.createBloc<BlocT, State>();
  }
}

/// Initialize [Isolate], ServiceEventListener in both Isolates and run [Initializer].
/// If already initialized and [reCreate] is true kill previous [Isolate] and reinitialize everything.
Future<void> initialize(
  Initializer userInitializer, {
  PlatformChannelSetup platformChannelSetup = const PlatformChannelSetup(),
  bool reCreate = false,
}) async {
  assert(
    !reCreate && BlocManager.instance == null,
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
