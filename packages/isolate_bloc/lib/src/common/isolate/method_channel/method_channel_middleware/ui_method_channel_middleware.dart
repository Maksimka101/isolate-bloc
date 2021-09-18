import 'dart:async';

import 'package:flutter/services.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:uuid/uuid.dart';

/// This class receives messages from [MethodChannel.setMessageHandler]
/// registered in [MethodChannelSetup] and sends messages received from Isolate.
class UIMethodChannelMiddleware {
  /// Creates new middleware and sets [instance].
  UIMethodChannelMiddleware({
    required MethodChannels methodChannels,
    required BinaryMessenger binaryMessenger,
    required IIsolateMessenger isolateMessenger,
    IdGenerator? idGenerator,
  })  : generateId = idGenerator ?? const Uuid().v4,
        _isolateMessenger = isolateMessenger,
        _methodChannels = methodChannels,
        _binaryMessenger = binaryMessenger {
    instance = this;
  }

  static UIMethodChannelMiddleware? instance;

  final String Function() generateId;
  final BinaryMessenger _binaryMessenger;
  final IIsolateMessenger _isolateMessenger;
  final MethodChannels _methodChannels;
  final _messageHandlersCompleter = <String, Completer<ByteData>>{};
  StreamSubscription<MethodChannelEvent>? _methodChannelEventsSubscription;

  /// Starts listening for [MethodChannelEvent]s from Isolate and sets middleware for [MethodChannel].
  void initialize() {
    _bindPlatformMessageHandlers();
    _methodChannelEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is MethodChannelEvent)
        .cast<MethodChannelEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  /// Free all resources and remove middleware from [MethodChannel]
  Future<void> dispose() async {
    await _methodChannelEventsSubscription?.cancel();
    _unbindPlatformMessageHandlers();
  }

  void _listenForMethodChannelEvents(MethodChannelEvent event) {
    switch (event.runtimeType) {
      case InvokePlatformChannelEvent:
        event = event as InvokePlatformChannelEvent;
        _send(event.channel, event.data, event.id);
        break;
      case MethodChannelResponseEvent:
        event = event as MethodChannelResponseEvent;
        _methodChannelResponse(event.id, event.data);
        break;
    }
  }

  /// Send response from IsolateBloc's MessageChannel to the main
  /// Isolate's platform channel.
  void _methodChannelResponse(String id, ByteData? response) {
    final completer = _messageHandlersCompleter.remove(id);
    if (completer == null) {
      throw _UnexpectedMethodChannelResponse();
    } else {
      completer.complete(response);
    }
  }

  /// Send event to the platform and send response to the IsolateBloc's Isolate.
  void _send(String channel, ByteData? message, String id) {
    _binaryMessenger.send(channel, message)?.then((response) =>
        _isolateMessenger.send(PlatformChannelResponseEvent(response, id)));
  }

  void _bindPlatformMessageHandlers() {
    for (final channel in _methodChannels) {
      _binaryMessenger.setMessageHandler(channel, (message) {
        final completer = Completer<ByteData>();
        final id = generateId();
        _messageHandlersCompleter[id] = completer;
        _isolateMessenger.send(InvokeMethodChannelEvent(message, channel, id));

        return completer.future;
      });
    }
  }

  void _unbindPlatformMessageHandlers() {
    for (final channel in _methodChannels) {
      _binaryMessenger.setMessageHandler(channel, null);
    }
  }
}

class _UnexpectedMethodChannelResponse implements Exception {
  @override
  String toString() {
    return "Failed to send response from IsolateBloc's MessageChannel "
        "to the main Isolate's platform channel.\n"
        "This is internal error";
  }
}
