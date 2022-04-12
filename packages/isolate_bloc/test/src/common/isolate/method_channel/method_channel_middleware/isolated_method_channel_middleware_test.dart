// ignore_for_file: no-equal-arguments, close_sinks
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mock/mock_isolate_messenger.dart';
import '../../../../../test_utils/messenger_utils.dart';
import 'mock_binary_messenger.dart';

void main() {
  late IsolatedMethodChannelMiddleware methodChannelMiddleware;
  late MethodChannels methodChannels;
  late IIsolateMessenger isolateMessenger;
  late BinaryMessenger binaryMessenger;
  IdGenerator? idGenerator;

  setUp(() {
    methodChannels = ['test'];
    isolateMessenger = MockIsolateMessenger();
    binaryMessenger = MockBinaryMessenger();

    methodChannelMiddleware = IsolatedMethodChannelMiddleware(
      methodChannels: methodChannels,
      binaryMessenger: binaryMessenger,
      isolateMessenger: isolateMessenger,
      idGenerator: idGenerator,
    );

    when(
      () => binaryMessenger.setMessageHandler(any(), any()),
    ).thenAnswer((invocation) {});
    when(
      () => binaryMessenger.handlePlatformMessage(any(), any(), any()),
    ).thenAnswer((invocation) async {});
  });

  void initializeManager(Stream<IsolateEvent> stream) {
    initializeMessenger(
        isolateMessenger: isolateMessenger, eventsStream: stream,);

    methodChannelMiddleware.initialize();
  }

  group('Test `initialize`', () {
    test('creates singleton', () {
      expect(IsolatedMethodChannelMiddleware.instance, isNotNull);
    });

    test('test `setMessageHandler`', () {
      final controller = StreamController<IsolateEvent>();

      initializeManager(controller.stream);

      verify(() => binaryMessenger.setMessageHandler(any(), any()))
          .called(methodChannels.length);
    });

    test('subscribe on messages stream', () async {
      final controller = StreamController<IsolateEvent>();
      initializeMessenger(
          isolateMessenger: isolateMessenger, eventsStream: controller.stream,);

      controller
          .add(InvokeMethodChannelEvent(null, methodChannels.first, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verifyNever(
        () => binaryMessenger.handlePlatformMessage(
            methodChannels.first, null, any(),),
      );

      methodChannelMiddleware.initialize();

      controller
          .add(InvokeMethodChannelEvent(null, methodChannels.first, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verify(
        () => binaryMessenger.handlePlatformMessage('test', null, any()),
      ).called(2);
    }, skip: true,);
  });

  test('test `dispose` method', () async {
    final controller = StreamController<IsolateEvent>();

    initializeManager(controller.stream);

    await methodChannelMiddleware.dispose();

    controller
        .add(InvokePlatformChannelEvent(null, methodChannels.first, 'id'));
    await Future.delayed(const Duration(milliseconds: 1));

    verifyNever(() => binaryMessenger.send(methodChannels.first, null));
  });
}
