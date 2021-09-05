import 'dart:async';

import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_isolated_method_channel_middleware.dart';
import 'package:uuid/uuid.dart';

/// This class receive messages from [MethodChannel.send] and sends them to the
/// main Isolate.
class IsolatedMethodChannelMiddleware extends IIsolatedMethodChannelMiddleware {
  IsolatedMethodChannelMiddleware({
    required List<String> channels,
    required this.platformMessenger,
    required IIsolateMessenger isolateMessenger,
    String Function()? generateId,
  })  : generateId = generateId ?? const Uuid().v4,
        super(isolateMessenger: isolateMessenger) {
    _bindMessageHandlers(channels);
  }

  final BinaryMessenger platformMessenger;
  final String Function() generateId;
  final _platformResponsesCompleter = <String, Completer<ByteData>>{};

  /// Handle platform messages and send them to it's [MessageChannel].
  @override
  void handlePlatformMessage(String channel, String id, ByteData? message) {
    platformMessenger.handlePlatformMessage(channel, message, (data) {
      isolateMessenger.send(MethodChannelResponseEvent(data, id));
    });
  }

  /// Sends response from platform channel to it's message handler.
  @override
  void platformChannelResponse(String id, ByteData? response) {
    final completer = _platformResponsesCompleter.remove(id);
    if (completer == null) {
      print(
        "Failed to send response from platform channel "
        "to it's message handler",
      );
    } else {
      completer.complete(response);
    }
  }

  void _bindMessageHandlers(List<String> channels) {
    for (final channel in channels) {
      platformMessenger.setMockMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _platformResponsesCompleter[id] = completer;
        isolateMessenger.send(InvokePlatformChannelEvent(message, channel, id));

        return completer.future;
      });
    }
  }
}
