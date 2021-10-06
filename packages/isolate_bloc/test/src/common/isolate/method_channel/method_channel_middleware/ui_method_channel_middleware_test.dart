// ignore_for_file: no-equal-arguments
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mock/mock_isolate_messenger.dart';
import '../../../../../test_utils/messenger_utils.dart';
import '../../../../../test_utils/method_channel_utils.dart';
import 'mock_binary_messenger.dart';

void main() {
  late UIMethodChannelMiddleware uiMethodChannelMiddleware;
  late MethodChannels methodChannels;
  late IIsolateMessenger isolateMessenger;
  late BinaryMessenger binaryMessenger;
  IdGenerator? idGenerator;

  setUp(() {
    methodChannels = ['test'];
    isolateMessenger = MockIsolateMessenger();
    binaryMessenger = MockBinaryMessenger();

    uiMethodChannelMiddleware = UIMethodChannelMiddleware(
      methodChannels: methodChannels,
      binaryMessenger: binaryMessenger,
      isolateMessenger: isolateMessenger,
      idGenerator: idGenerator,
    );

    when(
      () => binaryMessenger.setMessageHandler(any(), any()),
    ).thenAnswer((invocation) {});
  });

  void initializeManager(Stream<IsolateEvent> stream) {
    initializeMessenger(
        isolateMessenger: isolateMessenger, eventsStream: stream);

    uiMethodChannelMiddleware.initialize();
  }

  group('Test `initialize`', () {
    test('creates singleton', () {
      expect(UIMethodChannelMiddleware.instance, isNotNull);
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
          isolateMessenger: isolateMessenger, eventsStream: controller.stream);

      controller
          .add(InvokePlatformChannelEvent(null, methodChannels.first, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verifyNever(() => binaryMessenger.send(methodChannels.first, null));

      uiMethodChannelMiddleware.initialize();

      controller
          .add(InvokePlatformChannelEvent(null, methodChannels.first, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() => binaryMessenger.send(methodChannels.first, null)).called(2);
    });
  });

  group('Test send event to the platform', () {
    test('send event without response', () async {
      final request = byteDataEncode('test');
      when(() => binaryMessenger.send(methodChannels.first, request))
          .thenReturn(null);

      final controller = StreamController<IsolateEvent>();

      initializeManager(controller.stream);

      controller
          .add(InvokePlatformChannelEvent(request, methodChannels.first, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() => binaryMessenger.send(methodChannels.first, request))
          .called(1);
    });

    test('send event with response', () async {
      final channel = methodChannels.first;
      final request = byteDataEncode('request');
      final response = byteDataEncode('response');

      when(
        () => binaryMessenger.send(channel, request),
      ).thenAnswer((invocation) async => response);

      final controller = StreamController<IsolateEvent>();

      initializeManager(controller.stream);

      controller.add(InvokePlatformChannelEvent(request, channel, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      verify(() => isolateMessenger
          .send(PlatformChannelResponseEvent(response, 'id'))).called(1);
    });

    test('send multiple events with response', () async {
      final channel = methodChannels.first;
      final request = byteDataEncode('request');
      final response = byteDataEncode('response');

      when(
        () => binaryMessenger.send(channel, request),
      ).thenAnswer((invocation) async => response);
      final controller = StreamController<IsolateEvent>();

      initializeManager(controller.stream);

      for (var j = 0; j < 3; j++) {
        controller.add(InvokePlatformChannelEvent(
          request,
          channel,
          j.toString(),
        ));
      }

      await Future.delayed(const Duration(milliseconds: 1));

      for (var j = 0; j < 3; j++) {
        verify(
          () => isolateMessenger.send(PlatformChannelResponseEvent(
            response,
            j.toString(),
          )),
        ).called(1);
      }
    });

    test('send multiple events with response with multiple channels', () async {
      methodChannels = ['first', 'second', 'third'];
      final requests =
          methodChannels.map((e) => byteDataEncode('request$e')).toList();
      final responses =
          methodChannels.map((e) => byteDataEncode('response$e')).toList();

      for (var i = 0; i < methodChannels.length; i++) {
        when(
          () => binaryMessenger.send(methodChannels[i], requests[i]),
        ).thenAnswer((invocation) async => responses[i]);
      }
      final controller = StreamController<IsolateEvent>();

      initializeManager(controller.stream);

      for (var i = 0; i < methodChannels.length; i++) {
        for (var j = 0; j < 3; j++) {
          controller.add(InvokePlatformChannelEvent(
            requests[i],
            methodChannels[i],
            '${methodChannels[i]}$j',
          ));
        }
      }

      await Future.delayed(const Duration(milliseconds: 1));

      for (var i = 0; i < methodChannels.length; i++) {
        for (var j = 0; j < 3; j++) {
          verify(
            () => isolateMessenger.send(PlatformChannelResponseEvent(
              responses[i],
              '${methodChannels[i]}$j',
            )),
          ).called(1);
        }
      }
    });
  });

  group('Test send response from Isolate to the platform', () {
    setUp(() {
      binaryMessenger = _FakeBinaryMessenger();
    });

    test('test response handling', () async {
      final response = byteDataEncode('response');
      final request = byteDataEncode('request');
      final channel = methodChannels.first;
      final controller = StreamController<IsolateEvent>();

      idGenerator = () => 'id';
      uiMethodChannelMiddleware = UIMethodChannelMiddleware(
        methodChannels: methodChannels,
        binaryMessenger: binaryMessenger,
        isolateMessenger: isolateMessenger,
        idGenerator: idGenerator,
      );

      initializeManager(controller.stream);

      ByteData? receivedResponse;
      // ignore: unawaited_futures
      binaryMessenger.handlePlatformMessage(
          channel, request, (data) => receivedResponse = data);

      controller.add(MethodChannelResponseEvent(response, 'id'));
      await Future.delayed(const Duration(milliseconds: 1));

      expect(receivedResponse, response);
    });

    test('test multiple response handling', () async {
      methodChannels = ['first', 'second', 'third'];
      final responses =
          methodChannels.map((e) => byteDataEncode('response$e')).toList();
      final requests =
          methodChannels.map((e) => byteDataEncode('request$e')).toList();
      final controller = StreamController<IsolateEvent>();

      var count = 0;
      idGenerator = () => 'id${count++}';
      uiMethodChannelMiddleware = UIMethodChannelMiddleware(
        methodChannels: methodChannels,
        binaryMessenger: binaryMessenger,
        isolateMessenger: isolateMessenger,
        idGenerator: idGenerator,
      );

      initializeManager(controller.stream);

      final receiverResponses = <ByteData?>[];
      for (var i = 0; i < methodChannels.length; i++) {
        // ignore: unawaited_futures
        binaryMessenger.handlePlatformMessage(
          methodChannels[i],
          requests[i],
          (data) => receiverResponses.add(data),
        );

        controller.add(MethodChannelResponseEvent(responses[i], 'id$i'));
      }
      await Future.delayed(const Duration(milliseconds: 1));

      for (final response in receiverResponses) {
        expect(responses.contains(response), isTrue);
      }
    });
  });

  test('test `dispose` method', () async {
    final controller = StreamController<IsolateEvent>();

    initializeManager(controller.stream);

    await uiMethodChannelMiddleware.dispose();

    controller
        .add(InvokePlatformChannelEvent(null, methodChannels.first, 'id'));
    await Future.delayed(const Duration(milliseconds: 1));

    verifyNever(() => binaryMessenger.send(methodChannels.first, null));
  });
}

class _FakeBinaryMessenger extends BinaryMessenger {
  final _messageCallHandlers = <String, MessageHandler?>{};

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {
    callback?.call(await _messageCallHandlers[channel]?.call(data));
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    throw UnimplementedError();
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    _messageCallHandlers[channel] = handler;
  }
}
