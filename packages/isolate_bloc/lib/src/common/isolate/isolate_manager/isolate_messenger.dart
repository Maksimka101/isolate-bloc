/// Class that help communicate between [Isolate]s.
class IsolateMessenger {
  final Stream<Object> _fromIsolateStream;
  final void Function(Object message) _toIsolate;

  IsolateMessenger(this._fromIsolateStream, this._toIsolate);

  /// Receive messages from [Isolate]
  Stream<Object> get receiveMessages => _fromIsolateStream;

  /// Send messages to the [Isolate]
  void sendMessage(Object message) => _toIsolate(message);
}
