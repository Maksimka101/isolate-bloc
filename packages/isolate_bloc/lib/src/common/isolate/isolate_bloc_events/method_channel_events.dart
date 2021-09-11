// ignore_for_file: prefer-match-file-name
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

/// Event to invoke [MethodChannel] in main isolate.
class InvokePlatformChannelEvent extends MethodChannelEvent {
  InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel]
class PlatformChannelResponseEvent extends MethodChannelEvent {
  PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class InvokeMethodChannelEvent extends MethodChannelEvent {
  InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class MethodChannelResponseEvent extends MethodChannelEvent {
  MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}
