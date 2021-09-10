import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';

/// This class receive messages from [MethodChannel.send] and sends them to the
/// main Isolate.
abstract class IIsolatedMethodChannelMiddleware {
  IIsolatedMethodChannelMiddleware({
    required this.isolateMessenger,
  }) {
    instance = this;
  }

  static IIsolatedMethodChannelMiddleware? instance;
  final IIsolateMessenger isolateMessenger;

  /// Handle platform messages and send them to it's [MessageChannel].
  void handlePlatformMessage(String channel, String id, ByteData? message);

  /// Sends response from platform channel to it's message handler.
  void platformChannelResponse(String id, ByteData? response);
}
