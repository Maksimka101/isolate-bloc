import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

class EmittedCubit extends IsolateCubit {
  EmittedCubit() : super(Object());

  @override
  void onEventReceived(event) {
    expect(emitted, isFalse);
    emit("state");
    expect(emitted, isTrue);
  }
}
