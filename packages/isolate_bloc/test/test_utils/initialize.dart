import 'package:combine/combine.dart';
import 'package:isolate_bloc/src/common/isolate/initializer/isolate_initializer.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/combine_isolate_factory/combine_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

TestInitializePlatform _testInitializePlatform = TestInitializePlatform.native;

void testInitializePlatform(TestInitializePlatform platform) {
  _testInitializePlatform = platform;
}

Future<void> testInitialize(Initializer userInitializer) async {
  return IsolateInitializer().initialize(
    userInitializer,
    _testFactory,
  );
}

IIsolateFactory get _testFactory {
  switch (_testInitializePlatform) {
    case TestInitializePlatform.web:
      return CombineIsolateFactory(WebIsolateFactory());
    case TestInitializePlatform.native:
      return CombineIsolateFactory(NativeIsolateFactory());
  }
}

/// Platform which is used to determine which [IsolateCreateResult] implementation to use in tests.
/// Used to test both web and native backend.
enum TestInitializePlatform {
  web,
  native,
}
