import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';
import 'package:uuid/uuid.dart';

/// This class receives messages from [MethodChannel.setMessageHandler]
/// registered in [PlatformChannelSetup] and sends messages from [IsolateBloc]'s Isolate.
class MethodChannelMiddleware {
  MethodChannelMiddleware({
    @required List<String> channels,
    @required this.binaryMessenger,
    @required this.sendEvent,
    String Function() generateId,
  }) : generateId = generateId ?? Uuid().v4 {
    instance = this;
    _bindPlatformMessageHandlers(channels);
  }

  static MethodChannelMiddleware instance;
  final BinaryMessenger binaryMessenger;
  final void Function(ServiceEvent) sendEvent;
  final String Function() generateId;
  final _messageHandlersCompleter = <String, Completer<ByteData>>{};

  void _bindPlatformMessageHandlers(List<String> channels) {
    for (final channel in channels) {
      binaryMessenger.setMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _messageHandlersCompleter[id] = completer;
        sendEvent(InvokeMethodChannelEvent(message, channel, id));
        return completer.future;
      });
    }
  }

  /// Send response from [IsolateBloc]'s MessageChannel to the main
  /// Isolate's platform channel.
  void methodChannelResponse(String id, ByteData response) {
    _messageHandlersCompleter.remove(id).complete(response);
  }

  /// Send event to the platform and send response to the [IsolateBloc]'s Isolate.
  void send(String channel, ByteData message, String id) {
    binaryMessenger.send(channel, message).then(
        (response) => sendEvent(PlatformChannelResponseEvent(response, id)));
  }
}
