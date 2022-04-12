// ignore_for_file: close_sinks

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

import '../../../../blocs/counter_bloc.dart';
import '../../../../mock/mock_isolate_factory.dart';
import '../../../../mock/mock_isolate_messenger.dart';
import '../../../../test_utils/messenger_utils.dart';

void main() {
  late IsolateInitializer initializer;
  late IIsolateFactory isolateFactory;
  late IIsolateMessenger uiIsolateMessenger;
  late IIsolateMessenger isolatedMessenger;

  setUpAll(() {
    initializer = IsolateInitializer();

    uiIsolateMessenger = MockIsolateMessenger();
    isolatedMessenger = MockIsolateMessenger();

    isolateFactory = MockIsolateFactory(
      uiIsolateMessenger: uiIsolateMessenger,
      isolatedMessenger: isolatedMessenger,
    );
  });

  Future<void> initialize({
    required void Function() isolated,
    required StreamController<IsolateEvent> eventsController,
  }) async {
    initializeMessenger(
        isolateMessenger: uiIsolateMessenger,
        eventsStream: eventsController.stream,);
    initializeMessenger(isolateMessenger: isolatedMessenger);

    await initializer.initialize(
      () {
        isolated();
        eventsController.add(const IsolateBlocsInitialized({CounterBloc: 0}));
      },
      isolateFactory,
      [],
    );
    await Future.delayed(const Duration(milliseconds: 1));
  }

  test('test initializing stages', () async {
    var initializerCallCount = 0;
    final controller = StreamController<IsolateEvent>();

    await initialize(
      isolated: () => initializerCallCount++,
      eventsController: controller,
    );

    expect(initializerCallCount, 1);
    expect(UIIsolateManager.instance, isNotNull);
    expect(IsolateManager.instance, isNotNull);
  });
}
