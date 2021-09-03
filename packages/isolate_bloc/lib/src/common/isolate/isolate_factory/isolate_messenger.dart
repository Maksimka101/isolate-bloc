import 'dart:async';

typedef SendToIsolate = void Function(Object message);

/// Class that help communicate between [Isolate]s.
class IsolateMessenger {
  IsolateMessenger(this._fromIsolateStream, this._toIsolate);

  final Stream _fromIsolateStream;
  final SendToIsolate _toIsolate;

  /// Send messages to the [Isolate]
  void send(Object message) => _toIsolate(message);

  /// Stream with messages from [Isolate]
  Stream get messagesStream => _fromIsolateStream;
}
