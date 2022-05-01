import 'package:isolate_bloc/isolate_bloc.dart';

class ErrorCubit extends IsolateCubit {
  ErrorCubit() : super(Object());

  @override
  void onEventReceived(event) {
    throw ExpectedException();
  }
}

class ExpectedException {}
