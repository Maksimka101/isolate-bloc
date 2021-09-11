import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';

void main() {
  late WebIsolateFactory isolateFactory;
  late MethodChannels methodChannels;
  late IsolateRun isolateRun;
  late Initializer initializer;

  setUp(() {
    isolateFactory = WebIsolateFactory();
    isolateRun = (_, __) {};
    initializer = () {};
    methodChannels = ['test'];
  });

  test('test initializing', () async {
    var isolateRunCallTime = 0;
    isolateRun = (_, __) => isolateRunCallTime++;
    await isolateFactory.create(isolateRun, initializer, methodChannels);

    expect(UIMethodChannelMiddleware.instance, isNull);
    expect(IsolatedMethodChannelMiddleware.instance, isNull);
    expect(isolateRunCallTime, 1);
  });

  test('test isolate messenger', () async {
    IIsolateMessenger? isolateMessenger;
    isolateRun = (messenger, _) => isolateMessenger = messenger;

    var createResult = await isolateFactory.create(isolateRun, initializer, methodChannels);
    expect(isolateMessenger, isNotNull);

    isolateMessenger?.messagesStream.listen((event) {
      if (event is IsolateBlocTransitionEvent) {
        isolateMessenger?.send(IsolateBlocTransitionEvent('from_isolate', 'answer'));
      }
    });

    createResult.messenger.send(IsolateBlocTransitionEvent('to_isolate', 'test'));
    var answer = createResult.messenger.messagesStream.firstWhere((element) => element is IsolateBlocTransitionEvent);

    expect(await answer, IsolateBlocTransitionEvent('from_isolate', 'answer'));
  });
}
