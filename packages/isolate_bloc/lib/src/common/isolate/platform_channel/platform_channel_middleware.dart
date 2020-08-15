import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';
import 'package:uuid/uuid.dart';

class PlatformChannelMiddleware {
  static PlatformChannelMiddleware instance;
  final BinaryMessenger platformMessenger;
  final void Function(ServiceEvent) sendEvent;
  final String Function() generateId;
  final _messageHandlersCompleter = <String, Completer<ByteData>>{};

  PlatformChannelMiddleware({
    @required List<String> channels,
    @required this.platformMessenger,
    @required this.sendEvent,
    String Function() generateId,
  }) : generateId = generateId ?? Uuid().v4 {
    instance = this;
    _bindPlatformMessageHandlers(channels);
  }

  void _bindPlatformMessageHandlers(List<String> channels) {
    for (final channel in channels) {
      platformMessenger.setMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _messageHandlersCompleter[id] = completer;
        sendEvent(InvokeMethodChannelEvent(message, channel, id));
        return completer.future;
      });
    }
  }

  void methodChannelResponse(String id, ByteData response) {
    _messageHandlersCompleter.remove(id).complete(response);
  }

  void send(String channel, ByteData message, String id) {
    platformMessenger.send(channel, message).then(
        (response) => sendEvent(PlatformChannelResponseEvent(response, id)));
  }
}
