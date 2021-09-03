import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate/io_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_factory.dart';

TestInitializePlatform? _testInitializePlatform;

void testInitializePlatform(TestInitializePlatform platform) {
  _testInitializePlatform = platform;
}

Future<void> testInitialize(Initializer userInitializer) async {
  assert(
    _testInitializePlatform != null,
    "You are forget to set testInitializePlatform",
  );
  return IsolateInitializer().initialize(
    userInitializer,
    _testFactory,
    [],
  );
}

IsolateFactory get _testFactory {
  switch (_testInitializePlatform!) {
    case TestInitializePlatform.web:
      return WebIsolateFactory();
    case TestInitializePlatform.native:
      return IOIsolateFactory();
  }
}

/// Platform which is used to determine which [IsolateCreateResult] implementation to use in tests.
/// Used to test both web and native backend.
enum TestInitializePlatform {
  web,
  native,
}
