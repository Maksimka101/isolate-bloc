import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/isolate_manager.dart'
    as native_isolate;
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/isolate_manager.dart'
    as web_isolate;

TestInitializePlatform? _testInitializePlatform;

void testInitializePlatform(TestInitializePlatform platform) {
  _testInitializePlatform = platform;
}

Future<void> testInitialize(Initializer userInitializer) async {
  assert(
    _testInitializePlatform != null,
    "You are forget to set testInitializePlatform",
  );
  return BlocManager.initialize(
    userInitializer,
    () {
      switch (_testInitializePlatform!) {
        case TestInitializePlatform.web:
          return native_isolate.IsolateManagerImpl.createIsolate;
        case TestInitializePlatform.native:
          return web_isolate.WebIsolateManager.createIsolate;
      }
    }(),
    [],
  );
}

/// Platform which is used to determine which [IsolateManager] implementation to use in tests.
/// Used to test both web and native backends.
enum TestInitializePlatform {
  web,
  native,
}
