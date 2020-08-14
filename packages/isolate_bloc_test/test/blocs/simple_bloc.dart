import 'package:isolate_bloc/isolate_bloc.dart';

class SimpleBloc extends IsolateBloc<Object, Object> {
  SimpleBloc() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
