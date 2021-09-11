import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

typedef SendToIsolate = void Function(IsolateEvent message);

/// Class that help communicate between [Isolate]s.
class IsolateMessenger implements IIsolateMessenger {
  IsolateMessenger(this._fromIsolateStream, this._toIsolate);

  final Stream _fromIsolateStream;
  final SendToIsolate _toIsolate;

  /// Stream with messages from [Isolate]
  @override
  Stream<IsolateEvent> get messagesStream =>
      _fromIsolateStream.where((event) => event is IsolateEvent).cast<IsolateEvent>();

  /// Send messages to the [Isolate]
  @override
  void send(IsolateEvent message) => _toIsolate(message);
}
