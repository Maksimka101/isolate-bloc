import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';

typedef SendToIsolate = void Function(IsolateBlocEvent message);

/// Class that help communicate between [Isolate]s.
class IsolateMessenger {
  IsolateMessenger(this._fromIsolateStream, this._toIsolate);

  final Stream _fromIsolateStream;
  final SendToIsolate _toIsolate;

  /// Stream with messages from [Isolate]
  Stream<IsolateBlocEvent> get messagesStream =>
      _fromIsolateStream.where((event) => event is IsolateBlocEvent).cast<IsolateBlocEvent>();

  /// Send messages to the [Isolate]
  void send(IsolateBlocEvent message) => _toIsolate(message);
}
