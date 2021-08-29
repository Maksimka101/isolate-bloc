import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleBloc extends IsolateCubit<Object, Object> {
  SimpleBloc() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
