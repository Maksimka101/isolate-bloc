import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc_test/isolate_bloc_test.dart';

void main() {
  group('Simple test', () {
    test('Test correct initial state', () async {
      await initializeMock(initializer);
      expect(await createBloc<SimpleBloc, String>().first, '');
    });
  });
}

void initializer() {
  register(create: () => SimpleBloc());
}

class SimpleBloc extends IsolateBloc<Object, String> {
  SimpleBloc() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
