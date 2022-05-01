import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

/// {@template isolate_messenger}
/// Messenger for communication between `Isolate`s.
/// {@endtemplate}
abstract class IIsolateMessenger {
  /// Stream with messages from `Isolate`.
  Stream<IsolateEvent> get messagesStream;

  /// Sends messages to the `Isolate`.
  void send(IsolateEvent message);
}
