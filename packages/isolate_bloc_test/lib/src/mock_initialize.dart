import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

import 'mock_isolate_manager.dart';

/// Initialize all bloc's services.
/// Work like common initialize but doesn't create [Isolate]
Future<void> initializeMock(Initializer userInitializer) =>
    BlocManager.initialize(userInitializer, MockIsolateManager.createIsolate);
