import 'dart:async';

import 'package:flutter/services.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_method_channel_middleware.dart';
import 'package:uuid/uuid.dart';

/// This class receives messages from [MethodChannel.setMessageHandler]
/// registered in [MethodChannelSetup] and sends messages from [IsolateBloc]'s Isolate.
class MethodChannelMiddleware extends IMethodChannelMiddleware {
  MethodChannelMiddleware({
    required List<String> channels,
    required this.binaryMessenger,
    required IIsolateMessenger isolateMessenger,
    String Function()? generateId,
  })  : generateId = generateId ?? const Uuid().v4,
        super(isolateMessenger: isolateMessenger) {
    _bindPlatformMessageHandlers(channels);
  }

  final BinaryMessenger binaryMessenger;
  final String Function() generateId;
  final _messageHandlersCompleter = <String, Completer<ByteData>>{};

  /// Send response from [IsolateBloc]'s MessageChannel to the main
  /// Isolate's platform channel.
  @override
  void methodChannelResponse(String id, ByteData? response) {
    final completer = _messageHandlersCompleter.remove(id);
    if (completer == null) {
      print(
        "Failed to send response from IsolateBloc's MessageChannel "
        "to the main Isolate's platform channel.",
      );
    } else {
      completer.complete(response);
    }
  }

  /// Send event to the platform and send response to the [IsolateBloc]'s Isolate.
  @override
  void send(String channel, ByteData? message, String id) {
    binaryMessenger
        .send(channel, message)
        ?.then((response) => isolateMessenger.send(PlatformChannelResponseEvent(response, id)));
  }

  void _bindPlatformMessageHandlers(List<String> channels) {
    for (final channel in channels) {
      binaryMessenger.setMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _messageHandlersCompleter[id] = completer;
        isolateMessenger.send(InvokeMethodChannelEvent(message, channel, id));

        return completer.future;
      });
    }
  }
}
