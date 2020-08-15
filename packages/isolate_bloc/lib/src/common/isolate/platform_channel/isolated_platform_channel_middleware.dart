import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';
import 'package:uuid/uuid.dart';

class IsolatedPlatformChannelMiddleware {
  static IsolatedPlatformChannelMiddleware instance;
  final BinaryMessenger platformMessenger;
  final String Function() generateId;
  final void Function(ServiceEvent) sendEvent;
  final _platformResponsesCompleter = <String, Completer<ByteData>>{};

  IsolatedPlatformChannelMiddleware({
    @required List<String> channels,
    @required this.platformMessenger,
    String Function() generateId,
    @required this.sendEvent,
  }) : generateId = generateId ?? Uuid().v4 {
    instance = this;
    _bindMessageHandlers(channels);
  }

  void _bindMessageHandlers(List<String> channels) {
    for (final channel in channels) {
      platformMessenger.setMockMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _platformResponsesCompleter[id] = completer;
        sendEvent(InvokePlatformChannelEvent(message, channel, id));
        return completer.future;
      });
    }
  }

  void handlePlatformMessage(String channel, String id, ByteData message) {
    platformMessenger.handlePlatformMessage(channel, message, (data) {
      sendEvent(MethodChannelResponseEvent(data, id));
    });
  }

  void platformChannelResponse(String id, ByteData response) {
    _platformResponsesCompleter.remove(id).complete(response);
  }
}
