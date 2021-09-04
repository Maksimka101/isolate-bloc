import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc_test/isolate_bloc_test.dart';

void main() {
  group('Simple test', () {
    test('Test correct initial state', () async {
      await initializeMock(initializer);
      expect(await createBloc<SimpleCubit, String>().stream.first, '');
    });
  });
}

void initializer() {
  register<SimpleCubit, String>(create: () => SimpleCubit());
}

class SimpleCubit extends IsolateCubit<Object, String> {
  SimpleCubit() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
