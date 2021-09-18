import 'dart:async';
import 'dart:isolate';

import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

typedef SendToIsolate = void Function(IsolateEvent message);

/// {@macro isolate_messenger}
class IsolateMessenger implements IIsolateMessenger {
  /// {@macro isolate_messenger}
  ///
  /// Takes stream with messages from isolate
  /// and function which is used to send messages to isolate
  IsolateMessenger(this._fromIsolateStream, this._toIsolate);

  final Stream _fromIsolateStream;
  final SendToIsolate _toIsolate;

  /// Stream with messages from [Isolate]
  @override
  Stream<IsolateEvent> get messagesStream => _fromIsolateStream
      .where((event) => event is IsolateEvent)
      .cast<IsolateEvent>();

  /// Sends message to the [Isolate]
  @override
  void send(IsolateEvent message) => _toIsolate(message);
}
