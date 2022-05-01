import 'package:combine/combine.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

class CombineIsolateMessenger extends IIsolateMessenger {
  CombineIsolateMessenger(this.combineIsolateMessenger);

  final IsolateMessenger combineIsolateMessenger;

  @override
  Stream<IsolateEvent> get messagesStream {
    return combineIsolateMessenger.messages
        .where((message) => message is IsolateEvent)
        .cast<IsolateEvent>();
  }

  @override
  void send(IsolateEvent message) => combineIsolateMessenger.send(message);
}
