import 'dart:async';

import 'package:flutter/services.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:uuid/uuid.dart';

/// This class receive messages from [MethodChannel._send] and sends them to the
/// main Isolate.
class IsolatedMethodChannelMiddleware {
  IsolatedMethodChannelMiddleware({
    required this.methodChannels,
    required this.binaryMessenger,
    required this.isolateMessenger,
    IdGenerator? idGenerator,
  }) : generateId = idGenerator ?? const Uuid().v4 {
    instance = this;
  }

  static IsolatedMethodChannelMiddleware? instance;
  final IIsolateMessenger isolateMessenger;
  final BinaryMessenger binaryMessenger;
  final String Function() generateId;
  final MethodChannels methodChannels;
  final _platformResponsesCompleter = <String, Completer<ByteData>>{};
  StreamSubscription<MethodChannelEvent>? _methodChannelEventsSubscription;

  /// Starts listening for [MethodChannelEvent]s from ui
  void initialize() {
    _bindMessageHandlers();
    _methodChannelEventsSubscription = isolateMessenger.messagesStream
        .where((event) => event is MethodChannelEvent)
        .cast<MethodChannelEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  /// Free all resources
  Future<void> dispose() async {
    await _methodChannelEventsSubscription?.cancel();
    _unbindMessageHandlers();
  }

  void _listenForMethodChannelEvents(MethodChannelEvent event) {
    switch (event.runtimeType) {
      case PlatformChannelResponseEvent:
        event = event as PlatformChannelResponseEvent;
        _platformChannelResponse(event.id, event.data);
        break;
      case InvokeMethodChannelEvent:
        event = event as InvokeMethodChannelEvent;
        _handlePlatformMessage(
          event.channel,
          event.id,
          event.data,
        );
        break;
    }
  }

  /// Handle platform messages and send them to it's [MessageChannel].
  void _handlePlatformMessage(String channel, String id, ByteData? message) {
    binaryMessenger.handlePlatformMessage(channel, message, (data) {
      isolateMessenger.send(MethodChannelResponseEvent(data, id));
    });
  }

  /// Sends response from platform channel to it's message handler.
  void _platformChannelResponse(String id, ByteData? response) {
    final completer = _platformResponsesCompleter.remove(id);
    if (completer == null) {
      throw _UnexpectedPlatformChannelResponse();
    } else {
      completer.complete(response);
    }
  }

  void _bindMessageHandlers() {
    for (final channel in methodChannels) {
      binaryMessenger.setMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _platformResponsesCompleter[id] = completer;
        isolateMessenger.send(InvokePlatformChannelEvent(message, channel, id));

        return completer.future;
      });
    }
  }

  void _unbindMessageHandlers() {
    for (final channel in methodChannels) {
      binaryMessenger.setMessageHandler(channel, null);
    }
  }
}

class _UnexpectedPlatformChannelResponse implements Exception {
  @override
  String toString() {
    return "Failed to send response from platform channel "
        "to it's message handler.\nThis is internal error";
  }
}
