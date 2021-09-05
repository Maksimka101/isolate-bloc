import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleCubit extends IsolateCubit<Object, int> {
  SimpleCubit() : super(0);

  @override
  void onEventReceived(Object event) {
    emit(1);
  }
}
