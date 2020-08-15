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
  final _sendRequestsCompleter = <String, Completer<ByteData>>{};

  PlatformChannelMiddleware({
    @required List<String> channels,
    @required this.platformMessenger,
    @required this.sendEvent,
    String Function() generateId,
  }) : generateId = generateId ?? Uuid().v4 {
    instance = this;
  }

  void send(String channel, ByteData message, String id) {
    platformMessenger.send(channel, message).then(
        (response) => sendEvent(PlatformChannelResponseEvent(response, id)));
  }
}
