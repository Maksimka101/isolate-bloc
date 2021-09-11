import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

typedef SendToIsolate = void Function(IsolateEvent message);

/// Class that help communicate between [Isolate]s.
abstract class IIsolateMessenger {
  /// Stream with messages from [Isolate]
  Stream<IsolateEvent> get messagesStream;

  /// Send messages to the [Isolate]
  void send(IsolateEvent message);
}
