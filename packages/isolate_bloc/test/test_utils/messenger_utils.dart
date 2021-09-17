import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:mocktail/mocktail.dart';

void initializeMessenger({
  required IIsolateMessenger isolateMessenger,
  Stream<IsolateEvent>? eventsStream,
}) {
  when(() => isolateMessenger.messagesStream).thenAnswer(
    (_) async* {
      if (eventsStream != null) {
        yield* eventsStream;
      }
    },
  );
}
