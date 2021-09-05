import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

/// This class receives messages from [MethodChannel.setMessageHandler]
/// registered in [PlatformChannelSetup] and sends messages from [IsolateBloc]'s Isolate.
abstract class IMethodChannelMiddleware {
  IMethodChannelMiddleware({required this.isolateMessenger}) {
    instance = this;
  }

  static IMethodChannelMiddleware? instance;

  final IIsolateMessenger isolateMessenger;

  /// Send response from [IsolateBloc]'s MessageChannel to the main
  /// Isolate's platform channel.
  void methodChannelResponse(String id, ByteData? response);

  /// Send event to the platform and send response to the [IsolateBloc]'s Isolate.
  void send(String channel, ByteData? message, String id);
}
