import 'package:integration_tests/application/method_channel_scenario/method_channel_bloc.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

void isolateInitialization() {
  register<MethodChannelBloc, MethodChannelState>(
    create: () => MethodChannelBloc(),
  );
}
