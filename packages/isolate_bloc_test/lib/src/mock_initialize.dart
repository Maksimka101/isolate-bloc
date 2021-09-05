import 'package:isolate_bloc/isolate_bloc.dart';

import 'mock_isolate_manager.dart';

/// Initialize all bloc's services.
/// Work like common initialize but doesn't create [Isolate]
Future<void> initializeMock(
  Initializer userInitializer, {
  MethodChannelSetup platformChannelSetup = const MethodChannelSetup(),
}) {
  return IsolateInitializer().initialize(
    userInitializer,
    MockIsolateManagerFactory(),
    platformChannelSetup.methodChannels,
  );
}
