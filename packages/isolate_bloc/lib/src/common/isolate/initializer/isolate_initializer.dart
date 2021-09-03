import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

class IsolateInitializer {
  Future<void> initialize(
    Initializer initializer,
    IsolateFactory isolateFactory,
    MethodChannels platformChannels,
  ) async {
    // close current isolate
    UIIsolateManager.instance?.dispose();

    final createResult = await isolateFactory.create(
      _isolatedBlocRunner,
      initializer,
      platformChannels,
    );

    final uiIsolateManager = UIIsolateManager(createResult);

    // complete initialization
    await uiIsolateManager.initialize();
  }

  static Future<void> _isolatedBlocRunner(
    IsolateMessenger messenger,
    Initializer userInitializer,
  ) async {
    final isolateManager = IsolateManager(
      messenger: messenger,
      userInitializer: userInitializer,
    );

    await isolateManager.initialize();
  }
}
