import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleCubit extends IsolateCubit<Object, Object> {
  SimpleCubit() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
