import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/web/isolate_manager.dart';

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
    _testFactory,
    [],
  );
}

IsolateManagerFactory get _testFactory {
  switch (_testInitializePlatform!) {
    case TestInitializePlatform.web:
      return WebIsolateManagerFactory();
    case TestInitializePlatform.native:
      return IOIsolateManagerFactory();
  }
}

/// Platform which is used to determine which [IsolateManager] implementation to use in tests.
/// Used to test both web and native backend.
enum TestInitializePlatform {
  web,
  native,
}
