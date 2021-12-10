import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/web/web_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_setup.dart';

import '../../../../../blocs/counter_bloc.dart';

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
    expect(isolateRunCallTime, 0);

    await Future.delayed(Duration.zero);

    expect(isolateRunCallTime, 1);
  });

  test('test isolate messenger', () async {
    IIsolateMessenger? isolateMessenger;
    isolateRun = (messenger, _) => isolateMessenger = messenger;

    var createResult =
        await isolateFactory.create(isolateRun, initializer, methodChannels);
    await Future.delayed(Duration.zero);
    expect(isolateMessenger, isNotNull);

    isolateMessenger?.messagesStream.listen((event) {
      if (event is IsolateBlocTransitionEvent) {
        isolateMessenger
            ?.send(const IsolateBlocTransitionEvent('from_isolate', 'answer'));
      }
    });

    createResult.messenger
        .send(const IsolateBlocTransitionEvent('to_isolate', 'test'));
    var answer = createResult.messenger.messagesStream
        .firstWhere((element) => element is IsolateBlocTransitionEvent);

    expect(await answer,
        const IsolateBlocTransitionEvent('from_isolate', 'answer'));
  });

  test('test messages from `IIsolateMessenger` are not disappear', () async {
    final initialStates = {CounterBloc: 1};
    isolateRun = (messenger, _) =>
        messenger.send(IsolateBlocsInitialized(initialStates));

    final createResult =
        await isolateFactory.create(isolateRun, initializer, methodChannels);
    expect(await createResult.messenger.messagesStream.first,
        IsolateBlocsInitialized(initialStates));
  });
}
