import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';

typedef SendToIsolate = void Function(IsolateBlocEvent message);

/// Class that help communicate between [Isolate]s.
abstract class IIsolateMessenger {
  /// Stream with messages from [Isolate]
  Stream<IsolateBlocEvent> get messagesStream;

  /// Send messages to the [Isolate]
  void send(IsolateBlocEvent message);
}
